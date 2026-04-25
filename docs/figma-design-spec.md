# RallyMatch Figma Design Specification

## Color Palette

### Light Mode
| Name | Hex | Usage |
|------|-----|-------|
| Background | #F5F0E8 | Main app background |
| White | #FFFFFF | Cards, surfaces |
| Surface 2 | #EDE8DE | Secondary surfaces |
| Border | #E0D8CC | Borders |
| Accent | #5A8A00 | Primary (tennis green) |
| Accent 2 | #C8431A | Alerts (clay red) |
| Accent 3 | #8DB600 | Highlights |
| Text Primary | #111827 | Main text |
| Text Secondary | #4B5563 | Secondary text |
| Muted | #9CA3AF | Hints |

### Dark Mode
| Name | Hex |
|------|-----|
| Background | #0F110D |
| Surface | #181C14 |
| Accent | #8DB600 |
| Text | #F1F5E8 |

### Skill Badges
| Level | Background | Text |
|-------|------------|------|
| Advanced | #EAF5D3 | #3A6200 |
| Intermediate | #FFF4E6 | #C46A00 |
| Beginner | #EEF4FF | #3B6DD9 |

## Typography
- Display: Instrument Serif, 32px
- Body: Plus Jakarta Sans, 14px
- Badge: Plus Jakarta Sans, 10px, 700

## Components

### Player Card
- Container: 18px radius, white, shadow
- Avatar: 52x52px, gradient, 17px initials
- Match %: 26px Instrument Serif, accent color

### Profile Avatar
- Size: 76x76px
- Initials: 28px, 700

### Skill Badge
- Font: 10px, 700, uppercase
- Padding: 2px 8px
- Radius: 100px

## Screens

### Match Screen
- Top nav with logo + bell + avatar
- Sport toggle (Tennis/Padel/All)
- Filter chips (All Levels, Beginner, etc.)
- Player cards list
- Bottom nav (Home/Match/Schedule/Messages/Me)

### Profile Screen
- Back nav + menu
- Profile header with avatar, name, location, tags
- Stats row (Games/Rating/Years/Match %)
- About section
- Weekly availability grid
- Preferred courts tags
- CTA bar (Request Match + Message)

## Avatar Gradients
- ML: #5A8A00 → #8DB600
- SA: #7BC86C → #3D6200
- EK: #F48FB1 → #C2185B
- ZY: #FFCC80 → #E65100
- AK: #CE93D8 → #6A1B9A