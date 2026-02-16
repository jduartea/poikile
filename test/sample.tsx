// Poikile Theme — TSX / React Test File
//
// Colors vary by variant — see PALETTE.md for hex values per theme.
//
// Scopes to verify (in addition to all TS scopes):
//   entity.name.tag.tsx                  → tag  (JSX HTML tags)
//   punctuation.definition.tag.begin.tsx → tag  (< and >)
//   punctuation.definition.tag.end.tsx   → tag  (</>)
//   entity.other.attribute-name.tsx      → attribute  (JSX attributes / props)
//   support.class.component.tsx          → type  (capitalized JSX components)

import React, {
  useState,
  useEffect,
  useCallback,
  useMemo,
  useRef,
  createContext,
  useContext,
  type ReactNode,
  type FC,
  type ChangeEvent,
  type FormEvent,
} from "react";

// ── Types ───────────────────────────────────────────────────────────────

interface Todo {
  id: string;
  text: string;
  completed: boolean;
  priority: "low" | "medium" | "high";
  createdAt: Date;
}

interface TodoContextValue {
  todos: Todo[];
  filter: FilterState;
  addTodo: (text: string, priority: Todo["priority"]) => void;
  toggleTodo: (id: string) => void;
  removeTodo: (id: string) => void;
  setFilter: (filter: FilterState) => void;
  stats: { total: number; completed: number; pending: number };
}

type FilterState = "all" | "active" | "completed";

// ── Context ─────────────────────────────────────────────────────────────

const TodoContext = createContext<TodoContextValue | null>(null);

function useTodos(): TodoContextValue {
  const context = useContext(TodoContext);
  if (!context) {
    throw new Error("useTodos must be used within a TodoProvider");
  }
  return context;
}

// ── Provider ────────────────────────────────────────────────────────────

const TodoProvider: FC<{ children: ReactNode }> = ({ children }) => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [filter, setFilter] = useState<FilterState>("all");

  const addTodo = useCallback((text: string, priority: Todo["priority"]) => {
    const newTodo: Todo = {
      id: crypto.randomUUID(),
      text: text.trim(),
      completed: false,
      priority,
      createdAt: new Date(),
    };
    setTodos((prev) => [newTodo, ...prev]);
  }, []);

  const toggleTodo = useCallback((id: string) => {
    setTodos((prev) =>
      prev.map((todo) =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo,
      ),
    );
  }, []);

  const removeTodo = useCallback((id: string) => {
    setTodos((prev) => prev.filter((todo) => todo.id !== id));
  }, []);

  const stats = useMemo(() => {
    const completed = todos.filter((t) => t.completed).length;
    return {
      total: todos.length,
      completed,
      pending: todos.length - completed,
    };
  }, [todos]);

  const value = useMemo(
    () => ({ todos, filter, addTodo, toggleTodo, removeTodo, setFilter, stats }),
    [todos, filter, addTodo, toggleTodo, removeTodo, stats],
  );

  return <TodoContext.Provider value={value}>{children}</TodoContext.Provider>;
};

// ── Components ──────────────────────────────────────────────────────────

const PRIORITY_COLORS: Record<Todo["priority"], string> = {
  low: "#a3b87c",
  medium: "#d4a55c",
  high: "#d4626e",
};

function TodoForm() {
  const { addTodo } = useTodos();
  const [text, setText] = useState("");
  const [priority, setPriority] = useState<Todo["priority"]>("medium");
  const inputRef = useRef<HTMLInputElement>(null);

  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (text.trim().length === 0) return;
    addTodo(text, priority);
    setText("");
    inputRef.current?.focus();
  };

  return (
    <form onSubmit={handleSubmit} className="todo-form" role="form">
      <input
        ref={inputRef}
        type="text"
        value={text}
        onChange={(e: ChangeEvent<HTMLInputElement>) => setText(e.target.value)}
        placeholder="What needs to be done?"
        aria-label="New todo text"
        autoFocus
        className="todo-input"
      />
      <select
        value={priority}
        onChange={(e) => setPriority(e.target.value as Todo["priority"])}
        aria-label="Priority level"
        className="priority-select"
      >
        <option value="low">Low</option>
        <option value="medium">Medium</option>
        <option value="high">High</option>
      </select>
      <button type="submit" disabled={text.trim().length === 0}>
        Add
      </button>
    </form>
  );
}

interface TodoItemProps {
  todo: Todo;
  onToggle: () => void;
  onRemove: () => void;
}

const TodoItem: FC<TodoItemProps> = React.memo(({ todo, onToggle, onRemove }) => {
  const timeAgo = useMemo(() => {
    const seconds = Math.floor((Date.now() - todo.createdAt.getTime()) / 1000);
    if (seconds < 60) return `${seconds}s ago`;
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    return `${Math.floor(seconds / 86400)}d ago`;
  }, [todo.createdAt]);

  return (
    <li
      className={`todo-item ${todo.completed ? "completed" : ""}`}
      data-priority={todo.priority}
      data-testid={`todo-${todo.id}`}
    >
      <label className="todo-label">
        <input
          type="checkbox"
          checked={todo.completed}
          onChange={onToggle}
          aria-label={`Mark "${todo.text}" as ${todo.completed ? "incomplete" : "complete"}`}
        />
        <span
          className="todo-text"
          style={{
            textDecoration: todo.completed ? "line-through" : "none",
            opacity: todo.completed ? 0.6 : 1,
          }}
        >
          {todo.text}
        </span>
      </label>
      <span
        className="priority-badge"
        style={{ backgroundColor: PRIORITY_COLORS[todo.priority] }}
      >
        {todo.priority}
      </span>
      <time className="todo-time" dateTime={todo.createdAt.toISOString()}>
        {timeAgo}
      </time>
      <button
        onClick={onRemove}
        className="remove-btn"
        aria-label={`Remove "${todo.text}"`}
        title="Remove"
      >
        &times;
      </button>
    </li>
  );
});
TodoItem.displayName = "TodoItem";

function FilterBar() {
  const { filter, setFilter, stats } = useTodos();
  const filters: FilterState[] = ["all", "active", "completed"];

  return (
    <nav className="filter-bar" aria-label="Todo filters">
      <span className="stats">
        {stats.pending} item{stats.pending !== 1 ? "s" : ""} left
      </span>
      <div className="filter-buttons" role="group">
        {filters.map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={filter === f ? "active" : ""}
            aria-pressed={filter === f}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        ))}
      </div>
    </nav>
  );
}

function TodoList() {
  const { todos, filter, toggleTodo, removeTodo } = useTodos();

  const filteredTodos = useMemo(() => {
    switch (filter) {
      case "active":
        return todos.filter((t) => !t.completed);
      case "completed":
        return todos.filter((t) => t.completed);
      default:
        return todos;
    }
  }, [todos, filter]);

  if (filteredTodos.length === 0) {
    return (
      <div className="empty-state">
        <p>{filter === "all" ? "No todos yet. Add one above!" : `No ${filter} todos.`}</p>
      </div>
    );
  }

  return (
    <ul className="todo-list" role="list">
      {filteredTodos.map((todo) => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={() => toggleTodo(todo.id)}
          onRemove={() => removeTodo(todo.id)}
        />
      ))}
    </ul>
  );
}

// ── Generic Hook ────────────────────────────────────────────────────────

function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T | ((prev: T) => T)) => void] {
  const [stored, setStored] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item !== null ? (JSON.parse(item) as T) : initialValue;
    } catch {
      return initialValue;
    }
  });

  useEffect(() => {
    try {
      window.localStorage.setItem(key, JSON.stringify(stored));
    } catch (error) {
      console.error(`Failed to persist "${key}":`, error);
    }
  }, [key, stored]);

  return [stored, setStored];
}

// ── App ─────────────────────────────────────────────────────────────────

export default function App() {
  const [theme, setTheme] = useLocalStorage<"light" | "dark">("theme", "dark");

  return (
    <TodoProvider>
      <div className={`app ${theme}`} data-theme={theme}>
        <header className="app-header">
          <h1>Poikile Todos</h1>
          <button
            onClick={() => setTheme((t) => (t === "dark" ? "light" : "dark"))}
            aria-label={`Switch to ${theme === "dark" ? "light" : "dark"} mode`}
          >
            {theme === "dark" ? "☀️" : "🌙"}
          </button>
        </header>
        <main>
          <TodoForm />
          <FilterBar />
          <TodoList />
        </main>
        <footer className="app-footer">
          <p>
            Built with <strong>React</strong> &amp; <em>TypeScript</em>
          </p>
        </footer>
      </div>
    </TodoProvider>
  );
}
