# Poikile Theme — Python Test File
#
# Colors vary by variant — see PALETTE.md for hex values per theme.
#
# Scopes to verify:
#   keyword.control.python         → keyword  (if, elif, else, for, while, try, except, finally, with, as, return, yield, raise, pass, break, continue, assert, del)
#   keyword.control.import.python  → keyword  (import, from)
#   keyword.operator.logical.python → keyword (and, or, not, in, is)
#   keyword.operator.unpacking.python → keyword (*, **)
#   storage.type.function.python   → keyword  (def, lambda)
#   storage.type.class.python      → keyword  (class)
#   storage.modifier.python        → keyword  italic (async, await)
#   entity.name.function.python    → function  (function names)
#   support.function.builtin.python → function (print, len, range, type, isinstance, etc.)
#   entity.name.type.class.python  → type  (class names)
#   support.type.python            → type  (int, str, float, bool, list, dict, tuple, set, bytes, type)
#   entity.name.function.decorator.python → decorator italic (@decorator)
#   punctuation.definition.decorator.python → decorator italic
#   variable.language.python       → keyword  italic (self, cls)
#   variable.parameter.python      → fg.default  (parameters)
#   constant.language.python       → number  (True, False, None)
#   support.variable.magic.python  → decorator  (__init__, __name__, etc.)
#   storage.type.string.python     → regex  (f, r, b, u string prefixes)
#   meta.fstring.python            → regex
#   string.interpolated.python     → regex
#   meta.type.annotation.python    → type  (type hints)
#   string                         → string  (strings)
#   constant.numeric               → number  (numbers)
#   comment                        → fg.muted  italic

from __future__ import annotations

import asyncio
import json
import logging
import re
from abc import ABC, abstractmethod
from collections.abc import AsyncIterator, Callable, Sequence
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum, auto
from functools import wraps
from pathlib import Path
from typing import (
    Any,
    ClassVar,
    Final,
    Generic,
    Literal,
    Protocol,
    TypeAlias,
    TypeVar,
    overload,
    runtime_checkable,
)

logger = logging.getLogger(__name__)

# ── Type Variables & Aliases ─────────────────────────────────────────────

T = TypeVar("T")
E = TypeVar("E", bound=Exception)
JsonDict: TypeAlias = dict[str, Any]
Callback: TypeAlias = Callable[..., Any]

# ── Enums ────────────────────────────────────────────────────────────────


class Priority(Enum):
    LOW = auto()
    MEDIUM = auto()
    HIGH = auto()
    CRITICAL = auto()


class TaskStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


# ── Decorators ───────────────────────────────────────────────────────────


def retry(max_attempts: int = 3, delay: float = 1.0):
    """Decorator that retries a function on failure with exponential backoff."""

    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        @wraps(func)
        async def async_wrapper(*args: Any, **kwargs: Any) -> T:
            last_error: Exception | None = None
            for attempt in range(max_attempts):
                try:
                    return await func(*args, **kwargs)
                except Exception as e:
                    last_error = e
                    wait = delay * (2**attempt)
                    logger.warning(
                        f"Attempt {attempt + 1}/{max_attempts} failed: {e}. "
                        f"Retrying in {wait:.1f}s..."
                    )
                    await asyncio.sleep(wait)
            raise last_error  # type: ignore[misc]

        @wraps(func)
        def sync_wrapper(*args: Any, **kwargs: Any) -> T:
            last_error: Exception | None = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_error = e
                    import time

                    time.sleep(delay * (2**attempt))
            raise last_error  # type: ignore[misc]

        if asyncio.iscoroutinefunction(func):
            return async_wrapper  # type: ignore[return-value]
        return sync_wrapper  # type: ignore[return-value]

    return decorator


def validate_positive(func: Callable[..., T]) -> Callable[..., T]:
    """Ensure all numeric arguments are positive."""

    @wraps(func)
    def wrapper(*args: Any, **kwargs: Any) -> T:
        for arg in args:
            if isinstance(arg, (int, float)) and arg < 0:
                raise ValueError(f"Expected positive number, got {arg}")
        for key, val in kwargs.items():
            if isinstance(val, (int, float)) and val < 0:
                raise ValueError(f"Parameter '{key}' must be positive, got {val}")
        return func(*args, **kwargs)

    return wrapper  # type: ignore[return-value]


# ── Protocols ────────────────────────────────────────────────────────────


@runtime_checkable
class Serializable(Protocol):
    def to_dict(self) -> JsonDict: ...
    @classmethod
    def from_dict(cls, data: JsonDict) -> "Serializable": ...


class Repository(Protocol[T]):
    async def get(self, id: str) -> T | None: ...
    async def save(self, item: T) -> None: ...
    async def delete(self, id: str) -> bool: ...
    async def list_all(self, limit: int = 100, offset: int = 0) -> list[T]: ...


# ── Data Classes ─────────────────────────────────────────────────────────


@dataclass(frozen=True, slots=True)
class TaskConfig:
    timeout: float = 30.0
    max_retries: int = 3
    priority: Priority = Priority.MEDIUM
    tags: frozenset[str] = frozenset()

    def with_priority(self, priority: Priority) -> TaskConfig:
        return TaskConfig(
            timeout=self.timeout,
            max_retries=self.max_retries,
            priority=priority,
            tags=self.tags,
        )


@dataclass
class Task:
    id: str
    title: str
    description: str | None = None
    status: TaskStatus = TaskStatus.PENDING
    config: TaskConfig = field(default_factory=TaskConfig)
    created_at: datetime = field(default_factory=datetime.now)
    completed_at: datetime | None = None
    _attempt_count: int = field(default=0, repr=False)

    # Class variable shared by all instances
    MAX_TITLE_LENGTH: ClassVar[int] = 200

    def __post_init__(self) -> None:
        if len(self.title) > self.MAX_TITLE_LENGTH:
            raise ValueError(
                f"Title exceeds {self.MAX_TITLE_LENGTH} chars: "
                f"'{self.title[:50]}...'"
            )

    @property
    def is_terminal(self) -> bool:
        return self.status in (TaskStatus.COMPLETED, TaskStatus.FAILED, TaskStatus.CANCELLED)

    @property
    def duration(self) -> timedelta | None:
        if self.completed_at is None:
            return None
        return self.completed_at - self.created_at

    def to_dict(self) -> JsonDict:
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "status": self.status.value,
            "priority": self.config.priority.name.lower(),
            "created_at": self.created_at.isoformat(),
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "tags": sorted(self.config.tags),
        }

    @classmethod
    def from_dict(cls, data: JsonDict) -> Task:
        config = TaskConfig(
            priority=Priority[data.get("priority", "medium").upper()],
            tags=frozenset(data.get("tags", [])),
        )
        return cls(
            id=data["id"],
            title=data["title"],
            description=data.get("description"),
            status=TaskStatus(data.get("status", "pending")),
            config=config,
            created_at=datetime.fromisoformat(data["created_at"]),
        )


# ── Abstract Base Class ─────────────────────────────────────────────────


class BaseExecutor(ABC, Generic[T]):
    """Abstract base for task executors with lifecycle hooks."""

    REGISTRY: ClassVar[dict[str, type["BaseExecutor[Any]"]]] = {}

    def __init_subclass__(cls, executor_type: str | None = None, **kwargs: Any) -> None:
        super().__init_subclass__(**kwargs)
        if executor_type is not None:
            BaseExecutor.REGISTRY[executor_type] = cls

    @abstractmethod
    async def execute(self, task: Task) -> T:
        """Execute the task and return a result."""
        ...

    @abstractmethod
    async def rollback(self, task: Task, error: Exception) -> None:
        """Handle cleanup after a failed execution."""
        ...

    async def before_execute(self, task: Task) -> None:
        logger.info(f"Starting execution of task {task.id}")

    async def after_execute(self, task: Task, result: T) -> None:
        logger.info(f"Completed task {task.id}")


# ── Concrete Implementation ─────────────────────────────────────────────


class HttpExecutor(BaseExecutor[bytes], executor_type="http"):

    def __init__(self, base_url: str, *, verify_ssl: bool = True) -> None:
        self.base_url = base_url.rstrip("/")
        self.verify_ssl = verify_ssl
        self._session_count = 0

    @retry(max_attempts=3, delay=0.5)
    async def execute(self, task: Task) -> bytes:
        import aiohttp

        url = f"{self.base_url}/tasks/{task.id}/execute"
        timeout = aiohttp.ClientTimeout(total=task.config.timeout)

        async with aiohttp.ClientSession(timeout=timeout) as session:
            self._session_count += 1
            async with session.post(url, json=task.to_dict()) as resp:
                if resp.status != 200:
                    body = await resp.text()
                    raise RuntimeError(
                        f"HTTP {resp.status} from {url}: {body[:200]}"
                    )
                return await resp.read()

    async def rollback(self, task: Task, error: Exception) -> None:
        logger.error(f"Rolling back task {task.id}: {error}")


# ── Async Generator ─────────────────────────────────────────────────────


async def task_stream(
    tasks: Sequence[Task],
    *,
    batch_size: int = 10,
) -> AsyncIterator[tuple[Task, TaskStatus]]:
    """Yield tasks in batches with status updates."""
    for i in range(0, len(tasks), batch_size):
        batch = tasks[i : i + batch_size]
        results = await asyncio.gather(
            *[_process_single(t) for t in batch],
            return_exceptions=True,
        )
        for task, result in zip(batch, results):
            if isinstance(result, Exception):
                yield task, TaskStatus.FAILED
            else:
                yield task, TaskStatus.COMPLETED


async def _process_single(task: Task) -> None:
    await asyncio.sleep(0.01)


# ── Overloaded Functions ─────────────────────────────────────────────────


@overload
def parse_value(raw: str, as_type: Literal["int"]) -> int: ...
@overload
def parse_value(raw: str, as_type: Literal["float"]) -> float: ...
@overload
def parse_value(raw: str, as_type: Literal["bool"]) -> bool: ...
@overload
def parse_value(raw: str, as_type: Literal["str"]) -> str: ...


def parse_value(raw: str, as_type: str) -> int | float | bool | str:
    match as_type:
        case "int":
            return int(raw)
        case "float":
            return float(raw)
        case "bool":
            return raw.lower() in ("true", "1", "yes")
        case "str":
            return raw
        case _:
            raise ValueError(f"Unknown type: {as_type}")


# ── Context Manager ──────────────────────────────────────────────────────


class Timer:
    """Measure elapsed time as a context manager."""

    def __init__(self, label: str = "operation") -> None:
        self.label = label
        self.elapsed: float = 0.0
        self._start: float = 0.0

    def __enter__(self) -> "Timer":
        import time

        self._start = time.perf_counter()
        return self

    def __exit__(self, *exc: Any) -> None:
        import time

        self.elapsed = time.perf_counter() - self._start
        logger.info(f"{self.label} took {self.elapsed:.4f}s")


# ── String & Regex Patterns ──────────────────────────────────────────────

VERSION_PATTERN: Final[re.Pattern[str]] = re.compile(
    r"^v?(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)"
    r"(?:-(?P<pre>[a-zA-Z0-9.]+))?"
    r"(?:\+(?P<build>[a-zA-Z0-9.]+))?$"
)

MULTILINE_SQL = """
    SELECT t.id, t.title, t.status, c.priority
    FROM tasks t
    JOIN task_config c ON c.task_id = t.id
    WHERE t.status = 'pending'
      AND c.priority IN ('high', 'critical')
    ORDER BY t.created_at DESC
    LIMIT %(limit)s OFFSET %(offset)s
"""

RAW_PATH = r"C:\Users\admin\Documents\file.txt"
BYTE_STRING = b"\x00\x01\x02\xff"

# ── Numeric Literals ─────────────────────────────────────────────────────

PI: Final[float] = 3.14159_26535
HEX_COLOR: Final[int] = 0xFF_AA_00
OCTAL_PERMS: Final[int] = 0o755
BINARY_FLAGS: Final[int] = 0b1010_0101
BIG_NUMBER: Final[int] = 1_000_000_000
SCIENTIFIC: Final[float] = 6.022e23
NEGATIVE_EXP: Final[float] = 1.6e-19
COMPLEX_NUM: Final[complex] = 3 + 4j

# ── Main ─────────────────────────────────────────────────────────────────


async def main() -> None:
    config = TaskConfig(
        timeout=15.0,
        max_retries=5,
        priority=Priority.HIGH,
        tags=frozenset({"deploy", "production"}),
    )

    tasks = [
        Task(id=f"task-{i:03d}", title=f"Process batch #{i}", config=config)
        for i in range(1, 21)
    ]

    with Timer("batch processing"):
        async for task, status in task_stream(tasks, batch_size=5):
            symbol = "✓" if status == TaskStatus.COMPLETED else "✗"
            print(f"  {symbol} {task.id}: {status.value}")

    # Demonstrate various builtins
    lengths = list(map(len, [t.title for t in tasks]))
    total = sum(lengths)
    avg = total / len(lengths) if lengths else 0
    sorted_tasks = sorted(tasks, key=lambda t: t.title, reverse=True)
    unique_statuses = set(t.status for t in tasks)
    task_dict = {t.id: t.to_dict() for t in tasks[:3]}

    print(f"\nProcessed {len(tasks)} tasks")
    print(f"Average title length: {avg:.1f}")
    print(f"Unique statuses: {unique_statuses}")
    print(f"First 3 as JSON:\n{json.dumps(task_dict, indent=2)}")

    # Type checks
    assert isinstance(tasks[0], Task)
    assert not isinstance(tasks[0], str)
    assert issubclass(HttpExecutor, BaseExecutor)

    version_match = VERSION_PATTERN.match("v2.1.0-beta.1+build.42")
    if version_match is not None:
        print(f"Version: {version_match.group('major')}.{version_match.group('minor')}")

    value: int | str = parse_value("42", "int")
    assert value == 42 and type(value) is int

    # Walrus operator and comprehensions
    if (n := len(tasks)) > 10:
        heavy = [t for t in tasks if t.config.priority in (Priority.HIGH, Priority.CRITICAL)]
        print(f"{n} tasks total, {len(heavy)} are high priority")

    # Unpacking
    first, second, *rest = tasks
    print(f"First: {first.id}, remaining: {len(rest)}")


if __name__ == "__main__":
    asyncio.run(main())
