// Poikile Theme — TypeScript Test File
//
// Colors vary by variant — see PALETTE.md for hex values per theme.
//
// Scopes to verify:
//   keyword.control.ts                   → keyword  (if, else, for, while, return, switch, throw, try, catch, finally)
//   keyword.control.import.ts            → keyword  (import, export)
//   keyword.control.flow.ts              → keyword
//   storage.type.ts                      → keyword  (let, const, var, function, class, interface, type, enum)
//   storage.modifier.ts                  → keyword  italic (async, await, readonly, public, private, protected, static, abstract, override)
//   entity.name.function.ts              → function  (function names)
//   entity.name.type.ts                  → type  (type names)
//   entity.name.type.class.ts            → type  (class names)
//   entity.name.type.interface.ts        → type  (interface names)
//   entity.name.type.enum.ts             → type  (enum names)
//   entity.name.type.alias.ts            → type  (type alias names)
//   support.type.primitive.ts            → type  (string, number, boolean, void, never, unknown, any, null, undefined, bigint, symbol)
//   variable.other.readwrite.ts          → fg.default  (local variables)
//   variable.other.constant.ts           → constant  (const values)
//   variable.language.ts                 → keyword  italic (this, super, arguments)
//   string.template.ts                   → regex  (template literals)
//   punctuation.definition.template-expression → regex  (${...})
//   keyword.operator.type.ts             → keyword  (as, keyof, typeof, infer, extends)
//   keyword.operator.ternary.ts          → keyword
//   keyword.operator.spread.ts           → keyword
//   meta.arrow.ts                        → fg.subtle  (=>)
//   meta.type.annotation.ts              → type  (type annotations)
//   meta.type.parameters.ts              → type  (generics)
//   meta.decorator.ts                    → decorator  italic (@decorators)
//   meta.object-literal.key.ts           → fg.default  (object keys)
//   constant.language.ts                 → number  (true, false, null, undefined, NaN, Infinity)
//   meta.interface.ts                    → type

import { EventEmitter } from "events";
import type { Readable } from "stream";

// ── Type Aliases & Utility Types ────────────────────────────────────────

type Nullable<T> = T | null;
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};
type AsyncReturnType<T extends (...args: any[]) => Promise<any>> =
  T extends (...args: any[]) => Promise<infer R> ? R : never;

type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
type StatusCode = 200 | 201 | 204 | 400 | 401 | 403 | 404 | 500;

// ── Interfaces ──────────────────────────────────────────────────────────

interface Serializable {
  toJSON(): Record<string, unknown>;
}

interface Entity {
  readonly id: string;
  readonly createdAt: Date;
  updatedAt: Date;
}

interface Repository<T extends Entity> {
  findById(id: string): Promise<Nullable<T>>;
  findAll(options?: QueryOptions): Promise<PaginatedResult<T>>;
  save(entity: T): Promise<T>;
  delete(id: string): Promise<boolean>;
}

interface QueryOptions {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
  filters?: Record<string, unknown>;
}

interface PaginatedResult<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}

// ── Enums ───────────────────────────────────────────────────────────────

enum UserRole {
  Admin = "ADMIN",
  Editor = "EDITOR",
  Viewer = "VIEWER",
  Guest = "GUEST",
}

const enum LogLevel {
  Debug = 0,
  Info = 1,
  Warn = 2,
  Error = 3,
}

// ── Decorators ──────────────────────────────────────────────────────────

function logged(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const original = descriptor.value;
  descriptor.value = function (...args: unknown[]) {
    console.log(`→ ${propertyKey}(${args.map(String).join(", ")})`);
    const result = original.apply(this, args);
    if (result instanceof Promise) {
      return result.then((val: unknown) => {
        console.log(`← ${propertyKey} resolved`);
        return val;
      });
    }
    console.log(`← ${propertyKey} =`, result);
    return result;
  };
  return descriptor;
}

function validate(schema: Record<string, string>) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const original = descriptor.value;
    descriptor.value = function (...args: unknown[]) {
      for (const [key, type] of Object.entries(schema)) {
        const arg = (args[0] as Record<string, unknown>)?.[key];
        if (typeof arg !== type) {
          throw new TypeError(`Expected ${key} to be ${type}, got ${typeof arg}`);
        }
      }
      return original.apply(this, args);
    };
  };
}

// ── Classes ─────────────────────────────────────────────────────────────

abstract class BaseEntity implements Entity, Serializable {
  readonly id: string;
  readonly createdAt: Date;
  updatedAt: Date;

  constructor(id?: string) {
    this.id = id ?? crypto.randomUUID();
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }

  abstract toJSON(): Record<string, unknown>;

  touch(): void {
    (this as { updatedAt: Date }).updatedAt = new Date();
  }
}

class User extends BaseEntity {
  private _email: string;
  public name: string;
  protected role: UserRole;
  static readonly DEFAULT_ROLE = UserRole.Viewer;

  constructor(
    name: string,
    email: string,
    role: UserRole = User.DEFAULT_ROLE,
    id?: string,
  ) {
    super(id);
    this.name = name;
    this._email = email;
    this.role = role;
  }

  get email(): string {
    return this._email;
  }

  set email(value: string) {
    if (!value.includes("@")) {
      throw new Error(`Invalid email: "${value}"`);
    }
    this._email = value;
    this.touch();
  }

  get isAdmin(): boolean {
    return this.role === UserRole.Admin;
  }

  @logged
  async updateProfile(data: DeepPartial<{ name: string; email: string }>): Promise<void> {
    if (data.name !== undefined) this.name = data.name;
    if (data.email !== undefined) this.email = data.email;
    this.touch();
  }

  @validate({ name: "string" })
  rename(payload: { name: string }): void {
    this.name = payload.name;
    this.touch();
  }

  override toJSON(): Record<string, unknown> {
    return {
      id: this.id,
      name: this.name,
      email: this._email,
      role: this.role,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }

  override toString(): string {
    return `User(${this.name}, ${this._email})`;
  }
}

// ── Generics & Mapped Types ─────────────────────────────────────────────

class TypedEventEmitter<
  TEvents extends Record<string, (...args: any[]) => void>,
> {
  private emitter = new EventEmitter();

  on<K extends keyof TEvents & string>(event: K, listener: TEvents[K]): this {
    this.emitter.on(event, listener as (...args: any[]) => void);
    return this;
  }

  emit<K extends keyof TEvents & string>(
    event: K,
    ...args: Parameters<TEvents[K]>
  ): boolean {
    return this.emitter.emit(event, ...args);
  }

  off<K extends keyof TEvents & string>(event: K, listener: TEvents[K]): this {
    this.emitter.off(event, listener as (...args: any[]) => void);
    return this;
  }
}

// ── Async Patterns ──────────────────────────────────────────────────────

async function fetchWithRetry<T>(
  url: string,
  options?: {
    maxRetries?: number;
    backoffMs?: number;
    signal?: AbortSignal;
  },
): Promise<T> {
  const { maxRetries = 3, backoffMs = 1000, signal } = options ?? {};

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(url, {
        signal,
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      return (await response.json()) as T;
    } catch (error) {
      if (attempt === maxRetries) throw error;
      if (signal?.aborted) throw new DOMException("Aborted", "AbortError");

      const delay = backoffMs * Math.pow(2, attempt);
      console.warn(
        `Attempt ${attempt + 1}/${maxRetries} failed, retrying in ${delay}ms...`,
      );
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }

  throw new Error("Unreachable");
}

// ── Template Literals & String Manipulation ─────────────────────────────

function buildQuery(table: string, conditions: Record<string, unknown>): string {
  const entries = Object.entries(conditions);
  if (entries.length === 0) {
    return `SELECT * FROM "${table}"`;
  }

  const whereClauses = entries.map(
    ([key, value], index) => `"${key}" = $${index + 1}`,
  );

  return `SELECT * FROM "${table}" WHERE ${whereClauses.join(" AND ")}`;
}

// ── Control Flow & Pattern Matching ─────────────────────────────────────

function processValue(input: unknown): string {
  if (input === null || input === undefined) {
    return "empty";
  }

  if (typeof input === "string") {
    return input.length > 0 ? `string(${input.length})` : "empty_string";
  }

  if (typeof input === "number") {
    if (Number.isNaN(input)) return "NaN";
    if (!Number.isFinite(input)) return input > 0 ? "+Infinity" : "-Infinity";
    return `number(${input})`;
  }

  if (typeof input === "boolean") {
    return input ? "true" : "false";
  }

  if (Array.isArray(input)) {
    return `array[${input.length}]`;
  }

  if (typeof input === "object") {
    return `object{${Object.keys(input).length}}`;
  }

  return "unknown";
}

// ── Numeric Literals ────────────────────────────────────────────────────

const THRESHOLDS = {
  maxSize: 1_048_576,
  timeout: 30_000,
  hex: 0xff_aa_00,
  octal: 0o777,
  binary: 0b1010_1010,
  bigint: 9007199254740991n,
  scientific: 1.5e-10,
  negative: -273.15,
} as const;

// ── Discriminated Unions ────────────────────────────────────────────────

type Shape =
  | { kind: "circle"; radius: number }
  | { kind: "rectangle"; width: number; height: number }
  | { kind: "triangle"; base: number; height: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle":
      return Math.PI * shape.radius ** 2;
    case "rectangle":
      return shape.width * shape.height;
    case "triangle":
      return (shape.base * shape.height) / 2;
    default: {
      const _exhaustive: never = shape;
      return _exhaustive;
    }
  }
}

// ── Main ────────────────────────────────────────────────────────────────

async function main(): Promise<void> {
  const user = new User("Ada Lovelace", "ada@example.com", UserRole.Admin);
  console.log(user.toJSON());
  console.log(`Is admin: ${user.isAdmin}`);

  const shapes: Shape[] = [
    { kind: "circle", radius: 5 },
    { kind: "rectangle", width: 10, height: 20 },
    { kind: "triangle", base: 8, height: 6 },
  ];

  const areas = shapes.map((s) => ({
    kind: s.kind,
    area: area(s).toFixed(2),
  }));

  console.log("Areas:", JSON.stringify(areas, null, 2));

  const query = buildQuery("users", { role: "admin", active: true });
  console.log("Query:", query);

  for (const [key, value] of Object.entries(THRESHOLDS)) {
    console.log(`${key}: ${value}`);
  }
}

main().catch(console.error);
