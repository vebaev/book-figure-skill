# Book Figure semantic colors

Version: 1.1.0

Color expresses biological role consistently across the textbook. The same entity keeps the same fill and outline in every panel and figure. State changes are shown with arrows, inhibition bars, cleavage marks, opacity, or fragmentation—not by assigning a new unrelated color.

## Global colors

| Role | Fill / stroke | Outline |
| --- | --- | --- |
| Paper background | `#FCF7ED` | — |
| Alternate paper | `#FFFDF8` | — |
| Visible text | `#000000` | — |
| Primary outline and connector ink | `#203B57` | — |
| Secondary ink | `#42586B` | — |
| Neutral transition | `#C7C9C8` | — |

All letters, numbers, symbols, and punctuation intended to be read as text use `#000000`, regardless of the color of the biological object beneath or beside them. This includes nucleotide sequences and their 5′/3′ markers. Reserve `#203B57` for non-text object outlines, arrows, connectors, and process marks.

## Nucleic acids

| Role | Fill / strand | Outline |
| --- | --- | --- |
| DNA and genomic tracks | `#5AAFD2` | `#224E87` |
| Positive-sense RNA | `#79B86B` | `#397544` |
| Negative-sense RNA | `#4F7FB8` | `#224E87` |
| Unspecified or non-polar RNA | `#67B9B1` | `#32736E` |
| Degraded nucleic-acid fragments | Preserve parent color at 70% opacity | Preserve parent outline |

## Proteins and complexes

| Role | Fill | Outline |
| --- | --- | --- |
| Activating/regulatory protein | `#EE8C80` | `#A84D4D` |
| Inhibitory/repressive protein | `#C7B0E2` | `#7B62A8` |
| Neutral enzyme or processing complex | `#E8DFC7` | `#B9AE91` |
| Teal binding or transport factor | `#67B9B1` | `#32736E` |

## Regulatory DNA modules

| Role | Fill | Outline |
| --- | --- | --- |
| Promoter | `#F2D79B` | `#A8792D` |
| Enhancer | `#A8B95D` | `#627D38` |
| Silencer | `#D98786` | `#8C4D55` |
| Insulator | `#AAB8CF` | `#5B6F92` |
| Gene body | `#5AAFD2` | `#224E87` |

## Compartments and plant structures

| Role | Fill | Boundary |
| --- | --- | --- |
| Nucleus | `#E9DFEC` | `#9A6F9C` |
| Chloroplast | `#E5F0D5` | `#7B8A52` |
| General cell/cytoplasm | `#EDF3F2` | `#8AA3AA` |
| Plant tissue or beneficial plant structure | `#A8B95D` | `#627D38` |

## Process and state encoding

- Active process arrow: `#203B57`.
- Neutral transition or degradation arrow: `#C7C9C8`.
- Inhibition: `#7B62A8` connector with a perpendicular terminal bar.
- Cleavage: two crisp `#203B57` cut marks at the molecular contact.
- Degradation: retain the molecule's semantic color, fragment it, and reduce opacity to 70%.
- Inactive state: retain entity color and use an inhibition bar or reduced saturation; do not recolor the entity as a different biological role.

## Assignment precedence

1. Assign color by biological identity: nucleic acid, protein role, regulatory module, or compartment.
2. Preserve that assignment when the same entity repeats across panels.
3. Encode activity, inhibition, cleavage, and degradation with process marks and state treatment.
4. If a protein has multiple roles, use the role central to the depicted mechanism and state the assignment in the prompt.
5. Pair every role color with a label, position, or distinct shape; never rely on color alone.
6. Avoid unlabeled red–green comparisons. Use shape and connector differences for color-vision accessibility.

## Prompt hand-off

Add a compact role map to every generation prompt:

```text
Semantic colors: all visible text #000000; DNA #5AAFD2/#224E87; positive RNA #79B86B/#397544; negative RNA #4F7FB8/#224E87; activator #EE8C80/#A84D4D; inhibitor #C7B0E2/#7B62A8; neutral enzyme #E8DFC7/#B9AE91; promoter #F2D79B/#A8792D. Preserve entity colors across panels and encode state with arrows, inhibition bars, cleavage, fragmentation, or opacity.
```
