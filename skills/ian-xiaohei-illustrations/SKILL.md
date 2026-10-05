---
name: ian-xiaohei-illustrations
description: Generate Ian-style Xiaohei article illustrations. Use for articles, posts, blogs, Notion docs, workflow docs, methods, processes, structures, states, metaphors, viewpoints, shot lists, image generation, or image edits that call for strange minimalist hand-drawn body illustrations. Default output language is English: clean white background, black hand drawing, sparse red/orange/blue handwritten English annotations, and the Xiaohei IP as the active conceptual actor.
---

# Ian Xiaohei Strange Article Illustrations

## Core Positioning

Design and generate 16:9 horizontal article illustrations in English by default. The goal is not commercial illustration, PPT infographics, or cute cartoons. The goal is to turn a key judgment, process, structure, state, or metaphor from the article into a clean, strange, imaginative, readable hand-drawn explanatory image that does not feel like an instruction manual.

The default visual IP is Xiaohei: a small solid-black figure with white dot eyes, thin legs, and a blank serious expression, doing something absurd but logically connected to the idea. Xiaohei must participate in the core action of the image, not stand nearby as decoration.

If the user explicitly asks for another language, use that language for annotations. Otherwise, all labels, shot lists, prompt text, and image annotations should be English.

## References To Read As Needed

Read only the references required by the task; do not load everything by default:

- `references/style-dna.md`: style DNA, color rules, text rules, and taboos.
- `references/xiaohei-ip.md`: Xiaohei appearance, personality, action library, and taboos.
- `references/composition-patterns.md`: structure types, original-metaphor method, and anti-copy rules.
- `references/prompt-template.md`: single-image prompt template.
- `references/qa-checklist.md`: post-generation checks and iteration rules.
- `assets/examples/`: low-frequency visual calibration only. Do not copy their compositions, objects, or labels.

## Workflow

### 1. Digest The Source

Read the article, link, Notion page, Markdown file, screenshot, or supplied content. Extract:

- the core claim;
- the paragraphs that carry a conceptual turn;
- the ideas that benefit from visual explanation;
- the parts that should stay as text and do not need an image.

Do not illustrate evenly. Prefer cognitive anchor points such as: a core judgment, two breakpoints, input-output loop, branching path, before/after contrast, one input becoming many outputs, handoff path, common trap, or role-state change.

### 2. Create A Shot List First When Asked

If the user asks to analyze where illustrations belong, provide a shot list first. For each image, state:

- placement after which paragraph or section;
- image theme;
- core meaning;
- structure type;
- what Xiaohei is doing;
- suggested elements;
- suggested English annotation words.

Default to 4-8 images. For short pieces use 1-3. For long pieces, avoid going beyond 9 unless there is a clear reason. Use enough images to clarify the writing, not turn it into a picture book.

### 3. Generate One Image At A Time

If the user explicitly asks to generate, output, make, or create images, do not wait for confirmation; use built-in `image_gen` for each image separately. Do not combine multiple images into one collage.

Each image explains one core structure. The prompt must include:

- 16:9 horizontal English article illustration;
- pure white background;
- black hand-drawn line art;
- sparse red/orange/blue handwritten English annotations;
- lots of empty white space;
- Xiaohei as the core action subject;
- no PPT, no commercial illustration, no childish cuteness, no complex architecture, no top-left structure title.

Do not copy prior examples. Examples provide style density and Xiaohei participation only. Do not reuse known compositions such as conveyor-belt breakpoints, Xiaohei pulling lines, material fish, stamped toolboxes, or common-trap paths unless the user explicitly asks to recreate a specific image. Re-invent a strange but fitting metaphor from the current article each time.

### 4. Check And Iterate

After generation, check `references/qa-checklist.md`. If any of these problems appear, regenerate or locally edit:

- Xiaohei is only decorative;
- the image is too full;
- it looks like a flowchart or PPT;
- there is too much text or the English labels are badly garbled;
- the top-left corner contains a type title such as "Workflow", "System Architecture", or "Common Traps";
- the style is too cute, childish, or stiff;
- the background is not clean white.

### 5. Save The Delivery

If the user is working inside a workspace, copy final images to:

```text
assets/<article-slug>-illustrations/
```

Name them in order:

```text
01-topic-name.png
02-topic-name.png
```

Keep original generated files. Do not overwrite existing assets unless the user explicitly asks to replace them.

## Response Style

Before generation, keep strategy output short and precise. After generation, include:

- how many images were generated;
- the purpose of each image;
- save paths;
- which images are strongest and which are optional.

Do not explain the style theory at length; let the images speak.
