# DITA-OT Markdown Template

Template repository for publishing **Markdown** output from DITA content using the [DITA-OT GitHub Action](https://github.com/dita-ot/dita-ot-action). Every push to the repository automatically runs DITA-OT and produces a downloadable Markdown artifact — no local toolchain required.

---

## Table of Contents

- [Prerequisite](#prerequisite)
- [Getting Started](#getting-started)
- [Grant Workflow Permissions](#grant-workflow-permissions)
- [Project Layout & Requirements](#project-layout--requirements)
- [Build & Download (CI Workflow)](#build--download-ci-workflow)
  - [How Chunking Works](#how-chunking-works)
  - [Downloading the Markdown Artifact](#downloading-the-markdown-artifact)
- [Filter Content with DITAVal](#filter-content-with-ditaval)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)

---

## Prerequisite

You must be logged in to a GitHub account. See [Creating an account on GitHub](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github) if you need one.

---

## Getting Started

1. Click **"Use this template"** at the top of this page.
2. Create your new repository from the template.
   - Select **"Include all branches"** so you get every branch the template provides.

---

## Grant Workflow Permissions

The built-in `GITHUB_TOKEN` must have write access for workflows to run correctly:

1. **Settings → Actions → General**
2. Under **Workflow permissions**, select **Read and write permissions**
3. (Optional but recommended) Check **Allow GitHub Actions to create and approve pull requests**

---

## Project Layout & Requirements

Put all DITA content inside the `dita` directory:

```
├─ .github/
│  ├─ workflows/
│  │  └─ ci.yml              ← CI/CD pipeline (Markdown build)
│  └─ dita-ot/
│     └─ myfilter.ditaval    ← sample DITAVal filter (edit or delete)
└─ dita/
   ├─ document.ditamap       ← main map (required by the default workflow)
   ├─ index.dita             ← first topic / landing content
   ├─ *.dita                 ← your topic files
   └─ images/                ← images referenced by topics
```

**Requirements**

- **Main map name**: The workflow expects `document.ditamap` as the input file.
  If you rename the map, also update the `-i` flag in `.github/workflows/ci.yml`.
- **First topic**: Make `index.dita` the first `<topicref>` in `document.ditamap`
  so the output has a clear entry point.
- Keep all topics, maps, and media under `dita/`.

---

## Build & Download (CI Workflow)

Every **push to `master`** triggers the workflow defined in `.github/workflows/ci.yml`.
It installs the [`org.lwdita`](https://github.com/jelovirt/org.lwdita) plugin and runs:

```sh
dita -i dita/document.ditamap -o out/markdown -f markdown
```

The resulting Markdown files are zipped and uploaded as a **workflow artifact** named `dita-markdown`.

### How Chunking Works

By default DITA-OT writes one Markdown file per DITA topic. The **`chunk` attribute** lets you merge topics together — this is the DITA "chunk to content" feature.

**Merge the entire map into a single Markdown file**

Add `chunk="combine"` to the root `<map>` element in `document.ditamap`:

```xml
<map chunk="combine">
  ...
</map>
```

**Merge only one branch**

Add `chunk="combine"` to a parent `<topicref>` to fold its children into the parent's file:

```xml
<topicref href="overview.dita" chunk="combine">
  <topicref href="overview-details.dita"/>
  <topicref href="overview-notes.dita"/>
</topicref>
```

For the full specification, see the [DITA-OT chunking documentation](https://www.dita-ot.org/dev/topics/chunking).

### Downloading the Markdown Artifact

1. Go to the **Actions** tab in your repository.
2. Select the latest successful workflow run.
3. Scroll to the **Artifacts** section at the bottom of the run page.
4. Click **dita-markdown** to download a ZIP containing your Markdown files.

---

## Filter Content with DITAVal

A **DITAVal file** tells DITA-OT which content to include or exclude based on profiling attributes (`audience`, `platform`, `product`, etc.) set on DITA elements. This lets you produce different Markdown deliverables from a single source.

### Step 1 — Profile your DITA content

Add profiling attributes to elements in your topics:

```xml
<p audience="expert">Advanced configuration options for power users.</p>
<p audience="novice">Quick-start instructions for new users.</p>
```

### Step 2 — Edit the sample DITAVal file

A ready-to-edit template is at `.github/dita-ot/myfilter.ditaval`. Open it and set the `action` for each `<prop>` to `include` or `exclude`:

```xml
<val>
  <prop att="audience" val="expert"  action="exclude"/>
  <prop att="audience" val="novice"  action="include"/>
</val>
```

### Step 3 — Add the `--filter` flag in `ci.yml`

Open `.github/workflows/ci.yml` and add `--filter` to the `dita` command (look for the build step):

```yaml
build: |
  dita -i dita/document.ditamap \
       -o out/markdown \
       -f markdown \
       --filter=.github/dita-ot/myfilter.ditaval
```

**Multiple DITAVal files**: repeat `--filter` for each file to stack filters:

```yaml
build: |
  dita -i dita/document.ditamap \
       -o out/markdown \
       -f markdown \
       --filter=.github/dita-ot/audience-expert.ditaval \
       --filter=.github/dita-ot/platform-linux.ditaval
```

> **Tip:** You can create multiple workflow jobs, each using a different DITAVal, to produce audience-specific Markdown artifacts in a single CI run.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Workflow fails immediately | Missing `document.ditamap` | Confirm the file exists at `dita/document.ditamap` |
| Build errors in log | Invalid DITA markup or broken `href` references | Open the failed job log and fix the reported file/line |
| Artifact missing after green run | Upload step skipped | Check that `out/markdown` was produced; re-run the workflow |
| DITAVal has no effect | Filter attribute not on any element | Verify your topics use the same attribute name and value as the `<prop>` in the DITAVal |

---

## Credits

Thanks to the following DITA-OT experts and maintainers:

- Jason Fox
- Roger Sheen
- Jarno Elovirta (org.lwdita plugin)
