// Poikile Theme — Rust Test File
//
// Colors vary by variant — see PALETTE.md for hex values per theme.
//
// Scopes to verify:
//   keyword.control.rust          → keyword  (if, else, for, while, loop, match, return, break, continue, fn, let, mut, const, static, type, struct, enum, impl, trait, pub, use, mod, crate, self, super, as, where, unsafe, async, await, move, ref, dyn)
//   entity.name.function.rust     → function  (function names)
//   entity.name.type.rust         → type  (type names)
//   entity.name.type.struct.rust  → type  (struct names)
//   entity.name.type.enum.rust    → type  (enum names)
//   entity.name.type.trait.rust   → type  (trait names)
//   entity.name.namespace.rust    → namespace  (module/crate names)
//   entity.name.lifetime.rust     → decorator  italic ('a, 'static)
//   storage.type.rust             → type  (i32, u64, f64, bool, str, String, Vec, Option, Result, Box, Rc, Arc)
//   storage.modifier.rust         → keyword  italic (mut, pub, unsafe, async, const, static)
//   support.function.rust         → function
//   support.macro.rust            → function  (macro invocations)
//   meta.macro.rust               → function  (macro_rules!, println!, vec!, format!)
//   meta.attribute.rust           → decorator  italic (#[derive], #[cfg], #[test])
//   meta.generic.rust             → type  (generics <T>)
//   meta.impl.rust                → type
//   keyword.operator.rust         → fg.subtle
//   keyword.operator.borrow.rust  → fg.subtle  (&, &mut)
//   punctuation.definition.lifetime.rust → decorator italic
//   constant.language.rust        → number  (true, false)
//   string                        → string
//   constant.numeric              → number

use std::collections::HashMap;
use std::fmt;
use std::io::{self, Read, Write};
use std::sync::{Arc, Mutex, RwLock};

use serde::{Deserialize, Serialize};
use tokio::sync::mpsc;

// ── Constants ───────────────────────────────────────────────────────────

const MAX_RETRIES: u32 = 3;
const DEFAULT_TIMEOUT_MS: u64 = 30_000;
static GLOBAL_CONFIG: RwLock<Option<Config>> = RwLock::new(None);

// ── Enums ───────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Priority {
    Low,
    Medium,
    High,
    Critical,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TaskError {
    NotFound(String),
    Timeout { task_id: String, elapsed_ms: u64 },
    ExecutionFailed { task_id: String, reason: String },
    InvalidInput(String),
}

impl fmt::Display for TaskError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TaskError::NotFound(id) => write!(f, "Task not found: {}", id),
            TaskError::Timeout { task_id, elapsed_ms } => {
                write!(f, "Task {} timed out after {}ms", task_id, elapsed_ms)
            }
            TaskError::ExecutionFailed { task_id, reason } => {
                write!(f, "Task {} failed: {}", task_id, reason)
            }
            TaskError::InvalidInput(msg) => write!(f, "Invalid input: {}", msg),
        }
    }
}

impl std::error::Error for TaskError {}

// ── Traits ──────────────────────────────────────────────────────────────

pub trait Executor: Send + Sync {
    type Output;
    type Error: std::error::Error;

    fn execute(&self, task: &Task) -> Result<Self::Output, Self::Error>;
    fn name(&self) -> &str;
}

pub trait AsyncExecutor: Send + Sync {
    type Output;
    type Error: std::error::Error;

    async fn execute(&self, task: &Task) -> Result<Self::Output, Self::Error>;
    async fn rollback(&self, task: &Task, error: &Self::Error);
}

trait Describable {
    fn describe(&self) -> String;
    fn summary(&self) -> String {
        let desc = self.describe();
        if desc.len() > 80 {
            format!("{}...", &desc[..77])
        } else {
            desc
        }
    }
}

// ── Structs ─────────────────────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    pub base_url: String,
    pub timeout_ms: u64,
    pub max_retries: u32,
    pub verify_ssl: bool,
    #[serde(default)]
    pub tags: Vec<String>,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            base_url: String::from("https://api.example.com"),
            timeout_ms: DEFAULT_TIMEOUT_MS,
            max_retries: MAX_RETRIES,
            verify_ssl: true,
            tags: Vec::new(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct Task {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub priority: Priority,
    pub status: TaskStatus,
    pub metadata: HashMap<String, String>,
    created_at: std::time::Instant,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TaskStatus {
    Pending,
    Running,
    Completed,
    Failed,
}

impl Task {
    pub fn new(id: impl Into<String>, title: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            title: title.into(),
            description: None,
            priority: Priority::Medium,
            status: TaskStatus::Pending,
            metadata: HashMap::new(),
            created_at: std::time::Instant::now(),
        }
    }

    pub fn with_priority(mut self, priority: Priority) -> Self {
        self.priority = priority;
        self
    }

    pub fn with_description(mut self, desc: impl Into<String>) -> Self {
        self.description = Some(desc.into());
        self
    }

    pub fn with_metadata(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.metadata.insert(key.into(), value.into());
        self
    }

    pub fn elapsed(&self) -> std::time::Duration {
        self.created_at.elapsed()
    }

    pub fn is_terminal(&self) -> bool {
        matches!(self.status, TaskStatus::Completed | TaskStatus::Failed)
    }
}

impl Describable for Task {
    fn describe(&self) -> String {
        format!(
            "[{}] {} (priority: {:?}, status: {:?})",
            self.id, self.title, self.priority, self.status
        )
    }
}

impl fmt::Display for Task {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Task({}, \"{}\")", self.id, self.title)
    }
}

// ── Generics & Lifetimes ────────────────────────────────────────────────

pub struct Pool<'a, T: Send + Sync + 'a> {
    items: Vec<&'a T>,
    max_size: usize,
}

impl<'a, T: Send + Sync + 'a> Pool<'a, T> {
    pub fn new(max_size: usize) -> Self {
        Self {
            items: Vec::with_capacity(max_size),
            max_size,
        }
    }

    pub fn add(&mut self, item: &'a T) -> Result<(), &'static str> {
        if self.items.len() >= self.max_size {
            return Err("Pool is at capacity");
        }
        self.items.push(item);
        Ok(())
    }

    pub fn get(&self, index: usize) -> Option<&'a T> {
        self.items.get(index).copied()
    }

    pub fn drain(&mut self) -> Vec<&'a T> {
        std::mem::take(&mut self.items)
    }
}

fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() >= y.len() { x } else { y }
}

// ── Pipeline with channels ──────────────────────────────────────────────

pub struct Pipeline {
    workers: usize,
    tasks: Arc<Mutex<Vec<Task>>>,
}

impl Pipeline {
    pub fn new(workers: usize) -> Self {
        Self {
            workers: workers.max(1),
            tasks: Arc::new(Mutex::new(Vec::new())),
        }
    }

    pub fn add_task(&self, task: Task) {
        let mut tasks = self.tasks.lock().unwrap();
        tasks.push(task);
    }

    pub async fn run(&self) -> Result<Vec<String>, TaskError> {
        let (tx, mut rx) = mpsc::channel::<String>(self.workers * 2);

        let tasks = {
            let mut guard = self.tasks.lock().unwrap();
            std::mem::take(&mut *guard)
        };

        let task_chunks: Vec<Vec<Task>> = tasks
            .chunks(self.workers)
            .map(|chunk| chunk.to_vec())
            .collect();

        for chunk in task_chunks {
            let tx = tx.clone();
            tokio::spawn(async move {
                for task in chunk {
                    let msg = format!("Processed: {} ({:?})", task.id, task.priority);
                    let _ = tx.send(msg).await;
                }
            });
        }

        drop(tx);

        let mut results = Vec::new();
        while let Some(msg) = rx.recv().await {
            results.push(msg);
        }

        Ok(results)
    }
}

// ── Macros ──────────────────────────────────────────────────────────────

macro_rules! task_vec {
    ($($id:expr => $title:expr),+ $(,)?) => {
        vec![
            $(Task::new($id, $title)),+
        ]
    };
}

macro_rules! log_info {
    ($($arg:tt)*) => {
        println!("[INFO] {}", format!($($arg)*));
    };
}

// ── Closures, Iterators, Pattern Matching ───────────────────────────────

fn process_tasks(tasks: &[Task]) -> HashMap<Priority, Vec<&Task>> {
    let mut grouped: HashMap<Priority, Vec<&Task>> = HashMap::new();

    for task in tasks.iter().filter(|t| !t.is_terminal()) {
        grouped.entry(task.priority).or_default().push(task);
    }

    grouped
}

fn demonstrate_iterators(tasks: &[Task]) {
    let high_priority_ids: Vec<&str> = tasks
        .iter()
        .filter(|t| matches!(t.priority, Priority::High | Priority::Critical))
        .map(|t| t.id.as_str())
        .collect();

    let total_metadata: usize = tasks.iter().map(|t| t.metadata.len()).sum();

    let descriptions: Vec<String> = tasks
        .iter()
        .enumerate()
        .map(|(i, t)| format!("{}. {}", i + 1, t.summary()))
        .collect();

    println!("High priority: {:?}", high_priority_ids);
    println!("Total metadata entries: {}", total_metadata);
    for desc in &descriptions {
        println!("  {}", desc);
    }
}

// ── Unsafe & Raw Pointers ───────────────────────────────────────────────

unsafe fn raw_pointer_example() {
    let mut value: i32 = 42;
    let ptr: *mut i32 = &mut value;
    *ptr += 1;
    assert_eq!(*ptr, 43);
}

// ── Numeric Literals ────────────────────────────────────────────────────

fn numeric_examples() {
    let _integer: i32 = 1_000_000;
    let _float: f64 = 3.14159_26535;
    let _hex: u32 = 0xDEAD_BEEF;
    let _octal: u32 = 0o755;
    let _binary: u8 = 0b1010_0101;
    let _byte: u8 = b'A';
    let _negative: i64 = -9_223_372_036_854_775_807;
    let _scientific: f64 = 6.022e23;
}

// ── Tests ───────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_task_creation() {
        let task = Task::new("t-001", "Test task")
            .with_priority(Priority::High)
            .with_description("A test task for verification")
            .with_metadata("env", "test");

        assert_eq!(task.id, "t-001");
        assert_eq!(task.priority, Priority::High);
        assert!(task.description.is_some());
        assert!(!task.is_terminal());
        assert_eq!(task.metadata.get("env"), Some(&"test".to_string()));
    }

    #[test]
    fn test_longest() {
        let s1 = String::from("hello");
        let result;
        {
            let s2 = String::from("world!");
            result = longest(s1.as_str(), s2.as_str());
            assert_eq!(result, "world!");
        }
    }

    #[test]
    fn test_task_vec_macro() {
        let tasks = task_vec![
            "t-001" => "First task",
            "t-002" => "Second task",
            "t-003" => "Third task",
        ];
        assert_eq!(tasks.len(), 3);
    }

    #[tokio::test]
    async fn test_pipeline() {
        let pipeline = Pipeline::new(2);
        pipeline.add_task(Task::new("p-001", "Pipeline task 1"));
        pipeline.add_task(Task::new("p-002", "Pipeline task 2"));
        let results = pipeline.run().await.unwrap();
        assert_eq!(results.len(), 2);
    }
}

// ── Main ────────────────────────────────────────────────────────────────

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let tasks = task_vec![
        "t-001" => "Deploy service",
        "t-002" => "Run migrations",
        "t-003" => "Verify health checks",
        "t-004" => "Update DNS records",
    ];

    for task in &tasks {
        log_info!("{}", task.describe());
    }

    let grouped = process_tasks(&tasks);
    for (priority, group) in &grouped {
        println!("{:?}: {} tasks", priority, group.len());
    }

    demonstrate_iterators(&tasks);

    let pipeline = Pipeline::new(2);
    for task in tasks {
        pipeline.add_task(task);
    }

    let results = pipeline.run().await?;
    for result in &results {
        println!("  {}", result);
    }

    unsafe {
        raw_pointer_example();
    }

    numeric_examples();

    Ok(())
}
