<!--
  Poikile Theme — Vue (SFC) Test File
  Colors vary by variant — see PALETTE.md for hex values per theme.

  Scopes to verify:
    entity.name.tag.template.html.vue  → link      (<template> block tag)
    entity.name.tag.script.html.vue   → function  (<script> block tag)
    entity.name.tag.style.html.vue    → accent    (<style> block tag)
    entity.name.tag.template.vue / .script.vue / .style.vue → link (fallback)
    text.html.vue                     → fg.default (default text in .vue)
    text.html.vue entity.name.tag.custom.html     → link (Vue components: TransitionGroup, slot)
    entity.name.tag.html              → tag       (native: div, form, header, etc.)
    meta.directive.vue                → keyword   (v-if, v-for, v-model, :class, @click)
    entity.other.attribute-name.vue   → keyword
    entity.other.attribute-name.html  → attribute (class, type, placeholder)
    string.quoted.double.html         → fg.subtle  (attribute values)
    meta.interpolation.vue / meta.expression.vue  → string ({{ }})
    support.function.vue              → function  (defineProps, ref, computed, watch, onMounted)
    source.vue entity.name.function.ts            → function (addTask, toggleTask, formatDate)
    variable.other.vue                → decorator (tasks, filters, canAddTask, stats)
    entity.name.type.*.ts             → type      (Task, TaskFilters, Ref)
    keyword.control.ts                → keyword   (if, return, const)
    constant.language.ts              → number    (true, false, null)
    string.quoted.*.ts                → fg.subtle (string literals)
    comment                           → fg.muted  (// comments)
    All CSS/SCSS scopes apply within <style> blocks.
    All HTML scopes apply within <template> blocks.
-->

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted, provide, type Ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'

// ── Types ───────────────────────────────────────────────────────────

interface Task {
  id: string
  title: string
  completed: boolean
  priority: 'low' | 'medium' | 'high'
  createdAt: Date
}

interface TaskFilters {
  status: 'all' | 'active' | 'completed'
  priority: Task['priority'] | null
  search: string
}

type SortField = 'title' | 'priority' | 'createdAt'

// ── Props & Emits ───────────────────────────────────────────────────

const props = withDefaults(defineProps<{
  initialTasks?: Task[]
  maxTasks?: number
  showStats?: boolean
}>(), {
  initialTasks: () => [],
  maxTasks: 100,
  showStats: true,
})

const emit = defineEmits<{
  'task-created': [task: Task]
  'task-toggled': [id: string, completed: boolean]
  'task-deleted': [id: string]
  'filter-changed': [filters: TaskFilters]
}>()

// ── Reactive State ──────────────────────────────────────────────────

const tasks = ref<Task[]>([...props.initialTasks])
const newTaskTitle = ref('')
const newTaskPriority = ref<Task['priority']>('medium')
const filters = ref<TaskFilters>({
  status: 'all',
  priority: null,
  search: '',
})
const sortField = ref<SortField>('createdAt')
const sortAsc = ref(false)
const isLoading = ref(false)
const errorMessage = ref<string | null>(null)

// ── Computed Properties ─────────────────────────────────────────────

const filteredTasks = computed(() => {
  let result = [...tasks.value]

  // Filter by status
  if (filters.value.status === 'active') {
    result = result.filter(t => !t.completed)
  } else if (filters.value.status === 'completed') {
    result = result.filter(t => t.completed)
  }

  // Filter by priority
  if (filters.value.priority) {
    result = result.filter(t => t.priority === filters.value.priority)
  }

  // Search
  if (filters.value.search.trim()) {
    const query = filters.value.search.toLowerCase()
    result = result.filter(t => t.title.toLowerCase().includes(query))
  }

  // Sort
  result.sort((a, b) => {
    let cmp = 0
    switch (sortField.value) {
      case 'title':
        cmp = a.title.localeCompare(b.title)
        break
      case 'priority': {
        const order = { low: 0, medium: 1, high: 2 }
        cmp = order[a.priority] - order[b.priority]
        break
      }
      case 'createdAt':
        cmp = a.createdAt.getTime() - b.createdAt.getTime()
        break
    }
    return sortAsc.value ? cmp : -cmp
  })

  return result
})

const stats = computed(() => ({
  total: tasks.value.length,
  completed: tasks.value.filter(t => t.completed).length,
  pending: tasks.value.filter(t => !t.completed).length,
  completionRate: tasks.value.length > 0
    ? Math.round((tasks.value.filter(t => t.completed).length / tasks.value.length) * 100)
    : 0,
}))

const canAddTask = computed(() =>
  newTaskTitle.value.trim().length > 0 && tasks.value.length < props.maxTasks
)

// ── Methods ─────────────────────────────────────────────────────────

function addTask() {
  if (!canAddTask.value) return

  const task: Task = {
    id: crypto.randomUUID(),
    title: newTaskTitle.value.trim(),
    completed: false,
    priority: newTaskPriority.value,
    createdAt: new Date(),
  }

  tasks.value.unshift(task)
  newTaskTitle.value = ''
  emit('task-created', task)
}

function toggleTask(id: string) {
  const task = tasks.value.find(t => t.id === id)
  if (task) {
    task.completed = !task.completed
    emit('task-toggled', id, task.completed)
  }
}

function removeTask(id: string) {
  const index = tasks.value.findIndex(t => t.id === id)
  if (index !== -1) {
    tasks.value.splice(index, 1)
    emit('task-deleted', id)
  }
}

function clearCompleted() {
  tasks.value = tasks.value.filter(t => !t.completed)
}

function formatDate(date: Date): string {
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date)
}

// ── Watchers ────────────────────────────────────────────────────────

watch(filters, (newFilters) => {
  emit('filter-changed', { ...newFilters })
}, { deep: true })

watch(() => tasks.value.length, (count) => {
  if (count >= props.maxTasks) {
    errorMessage.value = `Task limit reached (${props.maxTasks})`
  } else {
    errorMessage.value = null
  }
})

// ── Lifecycle ───────────────────────────────────────────────────────

const router = useRouter()
const route = useRoute()

onMounted(async () => {
  isLoading.value = true
  try {
    // Simulate loading from URL params
    const statusParam = route.query.status as string | undefined
    if (statusParam && ['all', 'active', 'completed'].includes(statusParam)) {
      filters.value.status = statusParam as TaskFilters['status']
    }
  } finally {
    isLoading.value = false
  }
})

onUnmounted(() => {
  // Cleanup
})

// ── Provide to child components ─────────────────────────────────────

provide('tasks', tasks)
provide('stats', stats)
</script>

<template>
  <div class="task-manager" :class="{ 'is-loading': isLoading }">
    <!-- Header with stats -->
    <header class="task-header">
      <h1>Task Manager</h1>
      <div v-if="showStats" class="stats-bar">
        <span class="stat">{{ stats.total }} total</span>
        <span class="stat stat--success">{{ stats.completed }} done</span>
        <span class="stat stat--pending">{{ stats.pending }} left</span>
        <span class="stat stat--rate">{{ stats.completionRate }}%</span>
      </div>
    </header>

    <!-- Add Task Form -->
    <form class="add-form" @submit.prevent="addTask">
      <input
        v-model.trim="newTaskTitle"
        type="text"
        placeholder="What needs to be done?"
        class="task-input"
        :disabled="tasks.length >= maxTasks"
        @keyup.enter="addTask"
      >
      <select v-model="newTaskPriority" class="priority-select">
        <option value="low">Low</option>
        <option value="medium">Medium</option>
        <option value="high">High</option>
      </select>
      <button
        type="submit"
        class="btn btn--primary"
        :disabled="!canAddTask"
      >
        Add
      </button>
    </form>

    <!-- Error message -->
    <div v-if="errorMessage" class="error-banner" role="alert">
      {{ errorMessage }}
    </div>

    <!-- Filters -->
    <nav class="filter-bar">
      <div class="filter-group">
        <button
          v-for="status in (['all', 'active', 'completed'] as const)"
          :key="status"
          class="filter-btn"
          :class="{ active: filters.status === status }"
          @click="filters.status = status"
        >
          {{ status.charAt(0).toUpperCase() + status.slice(1) }}
        </button>
      </div>

      <input
        v-model="filters.search"
        type="search"
        placeholder="Search tasks..."
        class="search-input"
      >

      <button
        v-show="stats.completed > 0"
        class="btn btn--text"
        @click="clearCompleted"
      >
        Clear completed
      </button>
    </nav>

    <!-- Loading State -->
    <div v-if="isLoading" class="loading-spinner">
      <span class="sr-only">Loading tasks...</span>
    </div>

    <!-- Task List -->
    <TransitionGroup
      v-else-if="filteredTasks.length > 0"
      name="task-list"
      tag="ul"
      class="task-list"
    >
      <li
        v-for="task in filteredTasks"
        :key="task.id"
        class="task-item"
        :class="{
          'task-item--completed': task.completed,
          [`task-item--${task.priority}`]: true,
        }"
        :data-id="task.id"
      >
        <label class="task-label">
          <input
            type="checkbox"
            :checked="task.completed"
            @change="toggleTask(task.id)"
          >
          <span class="task-title">{{ task.title }}</span>
        </label>

        <span class="task-meta">
          <span
            class="priority-badge"
            :style="{ '--priority-color': task.priority === 'high' ? '#d4626e' : task.priority === 'medium' ? '#d4a55c' : '#a3b87c' }"
          >
            {{ task.priority }}
          </span>
          <time :datetime="task.createdAt.toISOString()">
            {{ formatDate(task.createdAt) }}
          </time>
        </span>

        <button
          class="btn btn--icon"
          aria-label="Remove task"
          @click.stop="removeTask(task.id)"
        >
          &times;
        </button>
      </li>
    </TransitionGroup>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <p v-if="filters.status === 'all' && !filters.search">
        No tasks yet. Add one above!
      </p>
      <p v-else>
        No {{ filters.status !== 'all' ? filters.status : '' }} tasks
        {{ filters.search ? `matching "${filters.search}"` : '' }} found.
      </p>
    </div>

    <!-- Slot for extensions -->
    <slot name="footer" :stats="stats" :task-count="filteredTasks.length" />
  </div>
</template>

<style scoped>
.task-manager {
  max-width: 640px;
  margin: 0 auto;
  padding: 2rem;
  font-family: 'Inter', system-ui, sans-serif;
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.task-header h1 {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--fg-bright, #e8e4dc);
}

.stats-bar {
  display: flex;
  gap: 0.75rem;
  font-size: 0.8125rem;
}

.stat {
  color: var(--fg-muted, #8a8784);
}

.stat--success { color: #7db87a; }
.stat--pending { color: #d4a55c; }
.stat--rate { color: #b48ead; }

.add-form {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.task-input {
  flex: 1;
  padding: 0.5rem 0.75rem;
  background: var(--bg-surface, #1e1e22);
  border: 1px solid var(--bg-selection, #3a3a44);
  border-radius: 6px;
  color: var(--fg-default, #d4d0c8);
  font-size: 0.875rem;
  transition: border-color 150ms ease;
}

.task-input:focus {
  outline: none;
  border-color: var(--accent, #b48ead);
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

.task-item--completed {
  opacity: 0.6;
}

.task-item--completed .task-title {
  text-decoration: line-through;
}

/* Transitions */
.task-list-enter-active,
.task-list-leave-active {
  transition: all 0.3s ease;
}

.task-list-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}

.task-list-leave-to {
  opacity: 0;
  transform: translateX(20px);
}

.loading-spinner {
  display: flex;
  justify-content: center;
  padding: 2rem;
}

.empty-state {
  text-align: center;
  padding: 2rem;
  color: var(--fg-muted, #8a8784);
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
