# Paralleles Scrollen mit OpenSeadragon (OSD)

## 1. Was ist das Ziel?

- Die Editionsseite zeigt **Text und Faksimile gleichzeitig nebeneinander**: links ein zoombarer Bildbetrachter (OSD), rechts der transkribierte TEI-Text.
- Beim **Scrollen im Text** soll der Viewer automatisch das Faksimile laden, das zur aktuell sichtbaren Textstelle gehört.
- Die Lösung muss natürlich möglichst **quelldokument-agnostisch**

---

## 2. Was muss am XSLT / HTML geändert werden?

- **Zweispaltiges Layout** erzeugen: Das `<div class="container">` bekommt eine neue Zeile (`editions-layout`) mit zwei festen Spalten:
  - Linke Spalte (`col-5 editions-viewer-col`): enthält `<div id="osd-viewer">` – der Anker für OSD.
  - Rechte Spalte (`col-7 editions-text-col`): enthält den transformierten TEI-Text.
- **Pro `<tei:pb>` exakt ein HTML-Marker** ausgeben (kein Duplizieren):
  - Das XSLT-Template `match="tei:pb"` löst `@facs` über die `<facsimile>`-Sektion auf.
  - Hat pb eine Bild-URL → `<span class="pb osd-marker" data-osd-image="…" data-osd-facs="…">`.
  - Direkt dahinter folgt `<br class="pb-break">` als sichtbarer Zeilenumbruch im Text.

- **OSD-Bibliothek und eigenes JS** am Ende des `<body>` einbinden:
  ```xml
  <script src="https://cdn.jsdelivr.net/npm/openseadragon@5.0/…/openseadragon.min.js"/>
  <script src="js/editions-osd.js"/>
  ```
- Eigenes CSS vor dem Zotero-Block im `<head>` laden:
  ```xml
  <link rel="stylesheet" href="css/editions-osd.css"/>
  ```

---

## 3. Was muss am CSS geändert werden?

- **`.editions-layout`** – `flex-wrap: nowrap` erzwingt das Nebeneinander auch bei schmalen Viewports; ohne das würden die Spalten untereinander rutschen und das Sticky-Verhalten bricht.
- **`.editions-viewer-col`** – `position: sticky; top: 0` hält die linke Spalte (mit OSD) beim Scrollen oben angeheftet. Sticky muss auf der *Spalte* (dem Bootstrap-`col`-`div`) liegen, nicht auf dem inneren `<aside>`, weil `sticky` nur greift, wenn das Element ein direktes Kind des scrollenden Containers ist.
- **`.osd-viewer`** – feste Höhe (`min(78vh, 62rem)`) damit OSD einen Zeichenbereich hat.
- **`.osd-marker`** – die PB-Marker sollen so klein wie möglich sein (ca. 0,45 rem), damit sie den Lesetext kaum stören; trotzdem können sie vom `IntersectionObserver` beobachtet werden.
- **`.pb-break`** – kleiner Zeilenumbruch nach jedem PB für visuelle Lesbarkeit.
- **`.pb.is-active`** – Hervorhebung (blaue Füllung) des PB-Labels, das zum aktuell gezeigten Bild gehört.
- **`.editions-text-column::after`** – unsichtbarer Nachlauf am Textende (`60vh`), damit auch der letzte Marker durch Scrollen in den Observer-Bereich gebracht werden kann.

---

## 4. IntersectionObserver – Wann feuert das Event?

Der `IntersectionObserver` ist eine Browser-API, die meldet, wenn ein Element einen definierten „Streifen“ im Viewport (dem sichtbaren Bereich des Browsers) **betritt oder verlässt** – ohne dauerhaftes `scroll`-Polling.

### Konfiguration in unserer Lösung

```js
new IntersectionObserver(callback, {
    root: null,                    // relativ zum Browser-Viewport
    rootMargin: "-15% 0px -65% 0px",  // aktiver Streifen
    threshold: 0                   // schon 1 sichtbares Pixel reicht
})
```

- **`root: null`** – der Viewport ist der Bezugsrahmen.
- **`rootMargin`** – verkleinert (oder vergrößert) den Beobachtungsrahmen:
  - `-15%` oben: der Streifen beginnt erst 15 % unterhalb der Viewport-Oberkante.
  - `-65%` unten: der Streifen endet bereits 35 % unterhalb der Viewport-Oberkante.
  - Effektiver Streifen: **15 % bis 35 % der Viewporthöhe** – entspricht ungefähr der Kopfregion des sichtbaren Textes.
- **`threshold: 0`** – das Event feuert, sobald auch nur 1 Pixel des Markers den Streifen berührt.

### Wann feuert das Event?

| Situation | Ergebnis |
|---|---|
| Marker scrollt in den aktiven Streifen | Event: `isIntersecting = true` → Marker in `intersecting`-Set aufnehmen |
| Marker scrollt aus dem Streifen heraus | Event: `isIntersecting = false` → Marker aus Set entfernen |
| Mehrere Marker gleichzeitig sichtbar | Alle im Set; der räumlich unterste wird für das Bild gewählt |
| Kein Marker im Streifen | Fallback: Bild über absolute Scrollposition bestimmen |
| Scroll-Position ≤ 5 px (Seitenanfang) | Immer Marker 0 / erstes Bild erzwingen |

### Debug-Overlay

```js
window.osdDebug()   // Overlay ein- / ausblenden (Toggle)
```

- **Blaues Band**: zeigt den aktiven Observer-Streifen im Viewport.
- **Grüner Punkt**: Marker liegt gerade im Streifen (`intersecting = true`).
- **Roter Punkt**: Marker liegt außerhalb des Streifens.
- Punkte aktualisieren sich live beim Scrollen.

---

## Relevante Dateien

| Datei | Aufgabe |
|---|---|
| `xslt/editions.xsl` | Haupttransformation: Layout, PB-Template, Asset-Einbindung |
| `html/css/editions-osd.css` | Sticky-Layout, Marker-Styling, Viewer-Größe, Debug-Punkte |
| `html/js/editions-osd.js` | OSD-Init, IntersectionObserver, Bildwechsel-Logik, Debug-Overlay |
| `data/editions/*.xml` | TEI-Quelldateien mit `<pb facs="…">` und `<facsimile><graphic url="…"/>` |
