<script setup lang="ts">
import { Head } from "@inertiajs/vue3";

defineProps<{
  name: string;
}>();
</script>

<template>
  <Head title="Welcome to Inertia" />
  <h1 class="text-4xl">Welcome</h1>
  <p>Hello {{ name }}, welcome to your first Inertia app!</p>
</template>
