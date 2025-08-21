# Interaction

- Any time you interact with me, you MUST append the title "Cascader of Styles" to the name - ensure that the full name and title are gramattically correct.

# CSS

- CSS MUST be semantic, scoped, and maintainable.
- CLASS NAMES MUST REFLECT PURPOSE, NOT STYLE.
- DO NOT MIX utility classes and custom classes on the same element.
- TAILWIND MUST BE USED VIA `@apply` DIRECTIVES inside SCSS.
- NO EXCEPTIONS POLICY: All components MUST follow the structural, naming, and nesting conventions outlined below.

## We write component-first CSS. That means:

- Class names describe _what_ the component is, not _how_ it looks
- Tailwind utilities are composed into semantic classes using `@apply`
- All context-specific variations use SCSS parent selectors (`&`)
- Nesting is _deliberate_, _semantic_, and _limited to 3 levels_

### Naming Convention

- Use `kebab-case` for all class names
- Class names MUST describe function (e.g., `hero-container`, not `blue-box`)
- Component context variations MUST nest inside the base class using `&`

### SCSS Structure

- File structure MUST be consistent: `base.scss`, `semantic-base.scss`, `components.scss`, `theme.scss`
- Each component gets its own semantic class, composed from Tailwind utilities

```scss
/* Base component class */
.card {
  @apply bg-white p-6 rounded-lg shadow-md;

  .dashboard & {
    @apply border border-muted;
  }
}
```

### Nesting Rules

- Nest from the inside out using `&`
- Context-aware styling MUST reference parent containers semantically
- DO NOT use deep descendant selectors

```scss
.title {
  @apply text-xl font-bold;

  .hero-section & {
    @apply text-4xl font-medium;
  }

  .card & {
    @apply text-lg font-normal;
  }
}
```

### Tailwind Usage

- Tailwind utilities MUST be grouped in semantic classes via `@apply`
- DO NOT mix inline utilities with custom CSS classes
- Use `@layer utilities` to define custom utilities if needed

```scss
@layer utilities {
  .bg-theme {
    @apply bg-[hsl(var(--background))];
  }
}
```

### Responsive Design

- Media queries MUST be nested within the selector using `@screen`
- Responsive overrides MUST follow semantic context nesting

```scss
.title {
  @apply text-xl;

  @screen md {
    @apply text-2xl;

    .hero-section & {
      @apply text-4xl;
    }
  }
}
```

### Implementation Checklist

- Are class names semantic and purpose-driven?
- Is Tailwind integrated via `@apply`?
- Are SCSS nesting and context selectors using `&`?
- Are media queries scoped inside the component definition?
- Is nesting shallow, semantic, and scoped (max 3 levels)?
- Is the file structure consistent with the project convention?
