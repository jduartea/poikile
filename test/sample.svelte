<!--
  Poikile Theme — Svelte Test File

  Colors vary by variant — see PALETTE.md for hex values per theme.

  Scopes to verify:
    keyword.control.svelte                 → keyword ({#if}, {#each}, {#await}, {:else}, {:then}, {:catch}, {/if}, {/each}, {/await})
    punctuation.definition.keyword.svelte  → keyword
    entity.name.tag.svelte                 → tag (Svelte tag names)
    entity.other.attribute-name.svelte     → attribute (attributes)
    meta.special-tag.svelte                → attribute (on:, bind:, class:, use:, transition:, animate:, in:, out:)
    variable.other.svelte                  → fg.default ($: reactive, $store)
    entity.name.function.svelte            → function (function names)

    All JS/TS scopes apply within <script> blocks.
    All CSS scopes apply within <style> blocks.
    All HTML scopes apply in the template.
-->

<script lang="ts">
  import { onMount, onDestroy, createEventDispatcher, tick } from 'svelte';
  import { writable, derived, type Writable, type Readable } from 'svelte/store';
  import { fly, fade, slide, scale } from 'svelte/transition';
  import { flip } from 'svelte/animate';
  import { quintOut } from 'svelte/easing';

  // ── Types ─────────────────────────────────────────────────────────

  interface Task {
    id: string;
    title: string;
    completed: boolean;
    priority: 'low' | 'medium' | 'high';
    createdAt: Date;
  }

  type FilterState = 'all' | 'active' | 'completed';

  // ── Props ─────────────────────────────────────────────────────────

  export let initialTasks: Task[] = [];
  export let maxTasks: number = 100;
  export let showStats: boolean = true;
  export let title: string = 'Task Manager';

  // ── Event dispatcher ──────────────────────────────────────────────

  const dispatch = createEventDispatcher<{
    'task-created': Task;
    'task-toggled': { id: string; completed: boolean };
    'task-deleted': string;
  }>();

  // ── Stores ────────────────────────────────────────────────────────

  const tasks: Writable<Task[]> = writable([...initialTasks]);
  const filter: Writable<FilterState> = writable('all');
  const searchQuery: Writable<string> = writable('');

  const filteredTasks: Readable<Task[]> = derived(
    [tasks, filter, searchQuery],
    ([$tasks, $filter, $searchQuery]) => {
      let result = [...$tasks];

      if ($filter === 'active') {
        result = result.filter(t => !t.completed);
      } else if ($filter === 'completed') {
        result = result.filter(t => t.completed);
      }

      if ($searchQuery.trim()) {
        const query = $searchQuery.toLowerCase();
        result = result.filter(t => t.title.toLowerCase().includes(query));
      }

      return result.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
    }
  );

  const stats: Readable<{ total: number; completed: number; pending: number; rate: number }> = derived(
    tasks,
    ($tasks) => {
      const completed = $tasks.filter(t => t.completed).length;
      return {
        total: $tasks.length,
        completed,
        pending: $tasks.length - completed,
        rate: $tasks.length > 0 ? Math.round((completed / $tasks.length) * 100) : 0,
      };
    }
  );

  // ── Reactive declarations ─────────────────────────────────────────

  let newTitle = '';
  let newPriority: Task['priority'] = 'medium';
  let inputElement: HTMLInputElement;
  let isLoading = false;

  $: canAdd = newTitle.trim().length > 0 && $tasks.length < maxTasks;
  $: taskCountLabel = `${$stats.pending} item${$stats.pending !== 1 ? 's' : ''} left`;
  $: hasCompletedTasks = $stats.completed > 0;

  // ── Methods ───────────────────────────────────────────────────────

  function addTask(): void {
    if (!canAdd) return;

    const task: Task = {
      id: crypto.randomUUID(),
      title: newTitle.trim(),
      completed: false,
      priority: newPriority,
      createdAt: new Date(),
    };

    tasks.update(list => [task, ...list]);
    newTitle = '';
    dispatch('task-created', task);

    tick().then(() => {
      inputElement?.focus();
    });
  }

  function toggleTask(id: string): void {
    tasks.update(list =>
      list.map(t => t.id === id ? { ...t, completed: !t.completed } : t)
    );
    const task = $tasks.find(t => t.id === id);
    if (task) {
      dispatch('task-toggled', { id, completed: task.completed });
    }
  }

  function removeTask(id: string): void {
    tasks.update(list => list.filter(t => t.id !== id));
    dispatch('task-deleted', id);
  }

  function clearCompleted(): void {
    tasks.update(list => list.filter(t => !t.completed));
  }

  function formatTime(date: Date): string {
    const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
    if (seconds < 60) return `${seconds}s ago`;
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    return `${Math.floor(seconds / 86400)}d ago`;
  }

  // ── Actions (use: directive) ──────────────────────────────────────

  function focusOnMount(node: HTMLElement) {
    node.focus();
    return {
      destroy() {
        // cleanup if needed
      }
    };
  }

  function clickOutside(node: HTMLElement, callback: () => void) {
    function handleClick(event: MouseEvent) {
      if (!node.contains(event.target as Node)) {
        callback();
      }
    }

    document.addEventListener('click', handleClick, true);

    return {
      destroy() {
        document.removeEventListener('click', handleClick, true);
      },
      update(newCallback: () => void) {
        callback = newCallback;
      }
    };
  }

  // ── Lifecycle ─────────────────────────────────────────────────────

  let interval: ReturnType<typeof setInterval>;

  onMount(async () => {
    isLoading = true;
    try {
      // Simulate async initialization
      await new Promise(resolve => setTimeout(resolve, 100));
    } finally {
      isLoading = false;
    }

    // Force re-render time labels every minute
    interval = setInterval(() => {
      tasks.update(t => t);
    }, 60_000);
  });

  onDestroy(() => {
    if (interval) clearInterval(interval);
  });

  // ── Constants ─────────────────────────────────────────────────────

  const PRIORITY_COLORS: Record<Task['priority'], string> = {
    low: '#a3b87c',
    medium: '#d4a55c',
    high: '#d4626e',
  };

  const FILTERS: FilterState[] = ['all', 'active', 'completed'];
</script>

<!-- Template with Svelte control flow -->
<div class="task-manager">
  <header class="header">
    <h1>{title}</h1>
    {#if showStats}
      <div class="stats" transition:fade={{ duration: 200 }}>
        <span>{$stats.total} total</span>
        <span class="success">{$stats.completed} done</span>
        <span class="pending">{taskCountLabel}</span>
        <span class="rate">{$stats.rate}%</span>
      </div>
    {/if}
  </header>

  <!-- Add task form -->
  <form class="add-form" on:submit|preventDefault={addTask}>
    <input
      bind:this={inputElement}
      bind:value={newTitle}
      use:focusOnMount
      type="text"
      placeholder="What needs to be done?"
      class="task-input"
      disabled={$tasks.length >= maxTasks}
      on:keydown={(e) => e.key === 'Escape' && (newTitle = '')}
    />
    <select bind:value={newPriority} class="priority-select">
      <option value="low">Low</option>
      <option value="medium">Medium</option>
      <option value="high">High</option>
    </select>
    <button type="submit" class="btn primary" disabled={!canAdd}>
      Add
    </button>
  </form>

  <!-- Filters -->
  <nav class="filter-bar">
    <div class="filter-group">
      {#each FILTERS as f (f)}
        <button
          class="filter-btn"
          class:active={$filter === f}
          on:click={() => filter.set(f)}
        >
          {f.charAt(0).toUpperCase() + f.slice(1)}
        </button>
      {/each}
    </div>

    <input
      type="search"
      placeholder="Search..."
      bind:value={$searchQuery}
      class="search-input"
    />

    {#if hasCompletedTasks}
      <button class="btn text" on:click={clearCompleted}>
        Clear completed
      </button>
    {/if}
  </nav>

  <!-- Loading state -->
  {#if isLoading}
    <div class="loading" in:fade={{ duration: 150 }}>
      <span class="sr-only">Loading tasks...</span>
    </div>

  <!-- Task list -->
  {:else if $filteredTasks.length > 0}
    <ul class="task-list">
      {#each $filteredTasks as task (task.id)}
        <li
          class="task-item"
          class:completed={task.completed}
          class:high={task.priority === 'high'}
          class:medium={task.priority === 'medium'}
          class:low={task.priority === 'low'}
          in:fly={{ y: -20, duration: 300, easing: quintOut }}
          out:fade={{ duration: 200 }}
          animate:flip={{ duration: 300 }}
        >
          <label class="task-label">
            <input
              type="checkbox"
              checked={task.completed}
              on:change={() => toggleTask(task.id)}
            />
            <span class="task-title" class:line-through={task.completed}>
              {task.title}
            </span>
          </label>

          <span class="task-meta">
            <span
              class="priority-badge"
              style="background-color: {PRIORITY_COLORS[task.priority]}"
            >
              {task.priority}
            </span>
            <time datetime={task.createdAt.toISOString()}>
              {formatTime(task.createdAt)}
            </time>
          </span>

          <button
            class="btn icon"
            aria-label="Remove task"
            on:click|stopPropagation={() => removeTask(task.id)}
          >
            &times;
          </button>
        </li>
      {/each}
    </ul>

  <!-- Empty state -->
  {:else}
    <div class="empty" transition:fade>
      {#if $filter === 'all' && !$searchQuery}
        <p>No tasks yet. Add one above!</p>
      {:else}
        <p>No matching tasks found.</p>
      {/if}
    </div>
  {/if}

  <!-- Async data example -->
  {#await fetch('/api/tips').then(r => r.json())}
    <p class="tip loading-tip">Loading tip...</p>
  {:then data}
    <p class="tip">{data.tip}</p>
  {:catch error}
    <p class="tip error-tip">Could not load tip: {error.message}</p>
  {/await}

  <!-- Slot -->
  <slot name="footer" stats={$stats} count={$filteredTasks.length} />
</div>

<style>
  .task-manager {
    max-width: 640px;
    margin: 0 auto;
    padding: 2rem;
    font-family: 'Inter', system-ui, sans-serif;
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
  }

  .header h1 {
    font-size: 1.5rem;
    font-weight: 700;
    color: #e8e4dc;
    margin: 0;
  }

  .stats {
    display: flex;
    gap: 0.75rem;
    font-size: 0.8125rem;
    color: #8a8784;
  }

  .stats .success { color: #7db87a; }
  .stats .pending { color: #d4a55c; }
  .stats .rate { color: #b48ead; }

  .add-form {
    display: flex;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .task-input {
    flex: 1;
    padding: 0.5rem 0.75rem;
    background: #1e1e22;
    border: 1px solid #3a3a44;
    border-radius: 6px;
    color: #d4d0c8;
    font-size: 0.875rem;
    transition: border-color 150ms ease;
  }

  .task-input:focus {
    outline: none;
    border-color: #b48ead;
  }

  .task-list {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  .task-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.625rem 0;
    border-bottom: 1px solid rgba(58, 58, 68, 0.5);
    transition: opacity 150ms ease;
  }

  .task-item.completed {
    opacity: 0.6;
  }

  .line-through {
    text-decoration: line-through;
  }

  .priority-badge {
    display: inline-block;
    padding: 0.125rem 0.5rem;
    border-radius: 100px;
    font-size: 0.6875rem;
    font-weight: 500;
    color: #141416;
  }

  .filter-bar {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1rem;
    flex-wrap: wrap;
  }

  .filter-btn {
    padding: 0.25rem 0.75rem;
    background: transparent;
    border: 1px solid #3a3a44;
    border-radius: 4px;
    color: #9b9baa;
    cursor: pointer;
    font-size: 0.8125rem;
    transition: all 150ms ease;
  }

  .filter-btn:hover {
    border-color: #9b9baa;
  }

  .filter-btn.active {
    background: #b48ead;
    border-color: #b48ead;
    color: #141416;
  }

  .empty {
    text-align: center;
    padding: 2rem;
    color: #8a8784;
  }

  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border: 0;
  }
</style>
