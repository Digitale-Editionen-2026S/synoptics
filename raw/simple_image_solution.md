# Bestehende Lösung: Bilder direkt im HTML

## Kurzbeschreibung

- Diese Lösung verwendet kein paralleles Scrollen mit dynamischem Bildwechsel.
- Stattdessen werden die Faksimile-Bilder direkt an den Stellen der TEI-`pb`-Elemente in das erzeugte HTML eingefügt.
- Dadurch steht im Lesetext bei jedem Seitenumbruch das zugehörige Bild.

## Wie funktioniert das?

- In `xslt/editions.xsl` wird das Partials-Stylesheet `xslt/partials/simple_images.xsl` importiert.
- Dieses Partial überschreibt die Standardverarbeitung von `tei:pb`.
- Für jedes `pb` wird über `@facs` die passende `graphic` im `facsimile` gesucht.
- Aus `graphic/@url` wird dann direkt ein HTML-`img` erzeugt.

## Verwendete Dateien

- `xslt/editions.xsl`
  - Haupt-XSLT für die Editionsseite.
  - Bindet das Partial `simple_images.xsl` ein.

- `xslt/partials/simple_images.xsl`
  - Rendert `tei:pb` direkt als:
    - `<div class="pb-image-wrap">`
    - `<img class="pb-image" src="...">`

- `html/css/simple_image.css`
  - Gestaltet die direkt eingebetteten Bilder.
  - In der aktuellen Fassung werden die Bilder im Textfluss zentriert dargestellt.

## Ergebnis im HTML

- In der generierten Datei erscheinen die Bilder direkt im Dokument, z. B. als:

```html
<div class="pb-image-wrap">
  <img class="pb-image" src="..." alt="Seitenbild: ...">
</div>
```

