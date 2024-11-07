#set text(font: "Atkinson Hyperlegible", lang: "de")
#show math.equation: set text(font: "STIX Two Math")

#let primary = rgb(10, 57, 129)
#let secondary = rgb(227, 142, 73)
#let tertiary = rgb(212, 235, 248)

#let title = "Mikrorechner Projekt"
#let date = datetime.today().display("[day].[month].[year]")

#set page(
  paper: "a4",
  margin: (top: 2.5cm, right: 3.5cm, bottom: 2.5cm),
  numbering: "1",
  header: context {
    let page_number = counter(page).get().first()

    if page_number > 1 {
      block(
        stroke: (bottom: 1pt + primary),
        inset: (bottom: 3pt),
        table(
          columns: (1fr, auto, 1fr),
          align: (left, center, right),
          stroke: none,
          title, [], date,
        ),
      )
    }
  },
  footer: context {
    let page_number = counter(page).get().first()

    block(
      width: 100%,
      stroke: (top: 1pt + primary),
      inset: (top: 6pt),
      align(center, [#page_number]),
    )
  },
)


#set heading(numbering: "1.1")

#show heading: it => (
  context {
    if it.numbering == none {
      return it
    }

    let num = text(weight: "thin", numbering(it.numbering, ..counter(heading).at(here())) + [ \u{200b}])
    let x-offset = -1 * measure(num).width

    let number = text(fill: primary.lighten(25%), num) + [] + text(fill: primary, it.body)

    pad(
      left: x-offset,
      par(hanging-indent: -1 * x-offset, number),
    )
  }
)

#set par(
  leading: .5em,
  justify: true,
)

#align(center, text(size: 18pt, fill: primary, weight: "bold", title))

= Allgemein

#lorem(30)

== Registers

Diese Tabelle beschreibt die Register unseres Prozessors und deren Funktionen. Sie umfasst die Nummerierung der Register, deren Namen sowie eine kurze Beschreibung ihres Zwecks. Register 0, \$z, ist ein schreibgeschütztes Nullregister, das spezielle Aufgaben erfüllt. Die Register 1 bis 29, \$1 bis \$29, sind Generalzweckregister und flexibel einsetzbar. Register 30, \$bp, fungiert als Basiszeiger für das Stackframe und erleichtert die Verwaltung von Funktionsaufrufen, während Register 31, \$sp, als Stackpointer die Spitze des Stacks anzeigt und für die Speicherverwaltung genutzt wird.

#table(
  columns: (auto, auto, 1fr),
  align: (center, center, left),
  table.header(
    repeat: true,
    [*Number*],
    [*Register*],
    [*Beschreibung*],
  ),

  [0], [\$z], [Nullregister (*READ ONLY*)],
  [1 - 29], [\$1 - \$29], [Generalzweck Register],
  [30], [\$bp], [Stackframe Basepointer],
  [31], [\$sp], [Stackpointer],
)

== Instruction Formats

Diese Tabelle beschreibt die Instruktionsformate unseres Prozessors, gegliedert nach den Typen R, I und J. Jede Instruktion wird durch die Verteilung ihrer Bits auf bestimmte Felder definiert, die in der Tabelle detailliert dargestellt sind.

#let cell(width, body) = {
  return table.cell(colspan: width, [#body \(#width)])
}

#table(
  columns: (auto, ..range(32).map(_ => 1fr)),
  align: (center, ..range(32).map(_ => center)),
  table.header(
    repeat: true,
    [*Type*],
    table.cell(colspan: 32, [*Bits*]),
  ),

  // R
  [R], cell(6, [opcode]),
  cell(5, [rs]), cell(5, [rt]),
  cell(5, [rd]), cell(5, [shamt]),
  cell(6, [funct]),
  // I
  [I],
  cell(6, [opcode]), cell(5, [rs]),
  cell(5, [rt]), cell(16, [immediate]),
  // J
  [J], cell(6, [opcode]), cell(26, [address])
)

== Instruction Reference

Diese Tabelle stellt die Instruktionen unseres Prozessors dar und bietet eine Übersicht über ihre wesentlichen Merkmale. Jede Zeile enthält den Op Code, der den Maschinenbefehl identifiziert, das Format, das die Struktur der Instruktion beschreibt, sowie den Mnemonic, eine lesbare Kurzform für den Befehl. Schließlich wird unter Action die Funktion der jeweiligen Instruktion beschrieben, also die Operation, die der Prozessor ausführt. Diese Darstellung erleichtert die Entwicklung und das Debugging von Programmen für unseren Prozessor.

#let substitutions = (
  (">>>", sym.gt.triple),
  (">>", sym.gt.double),
  (">", sym.gt),
  ("<<<", sym.lt.triple),
  ("<<", sym.lt.double),
  ("<", sym.lt),
  ("|", sym.or),
  ("&", sym.and),
)

#let substitute(body) = {
  let result = body

  for (pattern, replacement) in substitutions {
    result = result.replace(pattern, replacement)
  }

  return result
}

#let instructions = json("instructions.json").map(entry => (
  [#entry.opcode],
  entry.format,
  entry.mnemonic,
  math.equation(substitute(entry.meaning)),
))

#table(
  columns: (auto, auto, auto, 1fr),
  align: (center, center, left, left),
  table.header(
    repeat: true,
    [*Op Code*],
    [*Format*],
    [*Mnemonic*],
    [*Action*],
  ),
  ..instructions.flatten(),
)
