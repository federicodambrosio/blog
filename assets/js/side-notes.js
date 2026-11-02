(() => {
  const section = document.querySelector("article > section.prose");
  const content = section?.querySelector(":scope > div.min-w-0.max-w-prose");
  const footnotes = content?.querySelector(":scope > .footnotes");
  const footnoteList = footnotes?.querySelector(":scope > ol");

  if (!section || !content || !footnotes || !footnoteList) {
    return;
  }

  const notes = Array.from(footnoteList.children).filter((note) => note.id);
  const references = Array.from(content.querySelectorAll("a.footnote-ref"));
  const noteReferences = new Map();

  for (const reference of references) {
    const target = reference.getAttribute("href")?.slice(1);
    if (target && !noteReferences.has(target)) {
      noteReferences.set(target, reference);
    }
  }

  const positionedNotes = notes
    .map((note) => ({
      note,
      reference: noteReferences.get(note.id),
    }))
    .filter(({ reference }) => reference);

  if (positionedNotes.length === 0 || positionedNotes.length !== notes.length) {
    return;
  }

  const aside = document.createElement("aside");
  aside.className = "sidenotes";
  aside.setAttribute("aria-label", "Note a margine");
  aside.setAttribute("role", "doc-endnotes");
  const list = document.createElement("ol");
  aside.append(list);

  let enhanced = false;

  const restoreEndnotes = () => {
    if (!enhanced) {
      return;
    }

    for (const note of notes) {
      footnoteList.append(note);
      note.style.removeProperty("top");
      delete note.dataset.noteNumber;
    }
    aside.remove();
    section.classList.remove("has-sidenotes");
    enhanced = false;
  };

  const layoutSidenotes = () => {
    if (!window.matchMedia("(min-width: 1280px)").matches) {
      restoreEndnotes();
      return;
    }

    if (!enhanced) {
      for (const { note } of positionedNotes) {
        note.dataset.noteNumber = note.id.slice(note.id.indexOf(":") + 1);
        list.append(note);
      }
      section.append(aside);
      section.classList.add("has-sidenotes");
      enhanced = true;
    }

    const sectionRect = section.getBoundingClientRect();
    const contentRect = content.getBoundingClientRect();
    const gap = parseFloat(getComputedStyle(section).fontSize) * 2;
    aside.style.left = `${contentRect.right - sectionRect.left + gap}px`;

    const sectionTop = section.getBoundingClientRect().top;
    const orderedNotes = positionedNotes
      .map(({ note, reference }) => ({
        note,
        top: reference.getBoundingClientRect().top - sectionTop,
      }))
      .sort((a, b) => a.top - b.top);

    let nextAvailableTop = 0;
    for (const { note, top } of orderedNotes) {
      const placedTop = Math.max(top, nextAvailableTop);
      note.style.top = `${placedTop}px`;
      nextAvailableTop = placedTop + note.getBoundingClientRect().height + 20;
    }
  };

  let frame = 0;
  const scheduleLayout = () => {
    if (!frame) {
      frame = window.requestAnimationFrame(() => {
        frame = 0;
        layoutSidenotes();
      });
    }
  };

  window.addEventListener("resize", scheduleLayout, { passive: true });
  window.addEventListener("load", scheduleLayout);
  document.fonts?.ready.then(scheduleLayout);
  if ("ResizeObserver" in window) {
    new ResizeObserver(scheduleLayout).observe(content);
  }
  layoutSidenotes();
})();
