+++
title = "Markdown"
description = "Overview on the supported markdown, also showing how it is rendered by the theme."
date = "2025-03-30"
authors = ["Adrian Winterstein"]

[taxonomies]
tags=['Documentation']
+++

The following is supported to be used in the markdown files of any website using the Daisy theme.

## Headings

All six HTML heading types `<h1>` to `<h6>` are supported:

```markdown
# H1
## H2
### H3
#### H4
##### H5
###### H6
```

# H1
## H2
### H3
#### H4
##### H5
###### H6

<br>

## Text Formatting

Emphasis can be added to text like this:

```markdown
Text can be **strong**, *italic*, ***strong & italic***,
<u>underlined</u>, ~striked through~ or <mark>highlighted</mark>.
```

Text can be **strong**, *italic*, ***strong & italic***,
<u>underlined</u>, ~striked through~ or <mark>highlighted</mark>.

It is also possible to use subscripts and superscripts:

```markdown
y = a<sub>0</sub> + a<sub>1</sub>x + a<sub>2</sub>x<sup>2</sup>
```

y = a<sub>0</sub> + a<sub>1</sub>x + a<sub>2</sub>x<sup>2</sup>

## Blockquotes

Blockquotes without citation can be created like that:

```markdown
> Here is the **text** of the quote. \
> And here is a second line.
```

> Here is the **text** of the quote. \
> And here is a second line.

And a citation can be added this way:

```markdown
> So long, and thanks for all the fish. \
> ― <cite>Douglas Adams, The Hitchhiker’s Guide to the Galaxy[^1]</cite>
```

With the target of the citation to be added where it is supposed to appear (e.g., on the bottom of this example page):

```markdown
[^1]: The message, that was left by the dolphins when they departed earth in the fourth book.
```

> So long, and thanks for all the fish. \
> ― <cite>Douglas Adams, The Hitchhiker’s Guide to the Galaxy[^1]</cite>

## Lists

### Ordered Lists

```markdown
1. First Item
2. Second Item
3. Third Item
```

1. First Item
2. Second Item
3. Third Item

### Unordered Lists

```markdown
* First unordered item
* Second unordered item
  * First nested item
  * Second nested item
* Third unordered item
```

* First unordered item
* Second unordered item
  * First nested item
  * Second nested item
* Third unordered item

## Tables

```markdown
| First Column    | Second Column    |
| --------------- | ---------------- |
| First Row Left  | First Row Right  |
| Second Row Left | Second Row Right |
| Third Row Left  | Third Row Right  |
| Fourth Row Left | Fourth Row Right |
```

| First Column    | Second Column    |
| --------------- | ---------------- |
| First Row Left  | First Row Right  |
| Second Row Left | Second Row Right |
| Third Row Left  | Third Row Right  |
| Fourth Row Left | Fourth Row Right |

<br>

You can surround large tables with `<figure></figure>` to enable horizontal scrolling:

```markdown
<figure>

| First Column    | Second Column    | Third Column    | Fourth Column    | Fifth Column    | Sixth Column     | Seventh Column   | Eighth Column    |
| --------------- | ---------------- | --------------- | ---------------- | --------------- | ---------------- | ---------------- | ---------------- |
| First           | Second           | Third           | Fourth           | Fifth           | Sixth            | Seventh          | Eighth           |

</figure>
```

<figure>

| First Column    | Second Column    | Third Column    | Fourth Column    | Fifth Column    | Sixth Column     | Seventh Column   | Eighth Column    |
| --------------- | ---------------- | --------------- | ---------------- | --------------- | ---------------- | ---------------- | ---------------- |
| First           | Second           | Third           | Fourth           | Fifth           | Sixth            | Seventh          | Eighth           |

</figure>


## Foldable Text

Foldable text is possible with the use of some HTML in the markdown file:

```html
<details>
    <summary>The Title</summary>
    <p>This is the foldable content.</p>
</details>
```

<details>
    <summary>The Title</summary>
    <p>This is the foldable content.</p>
</details>

## Additional Items

### Abbrevations

```html
<abbr title="Hypertext Markup Language">HTML</abbr> tags are used for abbrevations.
```

<abbr title="Hypertext Markup Language">HTML</abbr> tags are used for abbrevations.

### Keyboard

```html
<kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Del</kbd>
```

<kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Del</kbd>

### Horizontal Line

```markdown
---
```

---

<br>

And at the end of the page, the citation from the blockquote above was added:

[^1]: The message, that was left by the dolphins when they departed earth in the fourth book.
