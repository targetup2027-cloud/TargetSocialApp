---
description: U-ΛXIS Brand Identity & UI/UX Design System - Senior Designer Guidelines
---

# U-ΛXIS Brand Identity System
## نظام الهوية البصرية - دليل كبير المصممين

---

## 1. BRAND ESSENCE (جوهر العلامة)

### Core Philosophy
- **Concept**: Orbital • Connected • Merit-Based
- **Tagline**: "REDEFINING EXCELLENCE"

### Brand Attributes
| Attribute | Description |
|-----------|-------------|
| **Tone** | Premium & Sophisticated |
| **Style** | Modern & Minimal |
| **Personality** | Bold & Confident |
| **Values** | Innovation & Excellence |

---

## 2. LOGO SYSTEM (نظام الشعار)

### Primary Wordmark
```
U-ΛXIS
```
- Font: Light weight (w200)
- Letter Spacing: 6px
- Color: #F0F0F0 (near white)
- Shadow: White glow with 15% opacity, blur 15

### Monogram
```
Λ
```
- Used on gradient backgrounds (Blue → Violet)
- Gradient: #3B82F6 → #8B5CF6

### Usage Rules
- Always use on dark backgrounds (#000000 or #0D0D0D)
- Maintain breathing room (minimum padding: 24px)
- Never distort or rotate the logo

---

## 3. COLOR PALETTE (لوحة الألوان)

### Official Brand Colors

| Section | Name | Arabic | Hex Code | Glow (25% opacity) |
|---------|------|--------|----------|-------------------|
| Discover | Blue | اكتشف | `#3B82F6` | `#403B82F6` |
| Social | Pink | اجتماعي | `#EC4899` | `#40EC4899` |
| Messages | Emerald | رسائل | `#10B981` | `#4010B981` |
| Business | Violet | أعمال | `#8B5CF6` | `#408B5CF6` |
| AI Hub | Cyan | مركز AI | `#06B6D4` | `#4006B6D4` |

### Marketplace Mapping
- **Commerce** = Messages (Emerald)
- **AI** = Business (Violet)
- **Premium** = Discover (Blue)

### Surface Colors
| Name | Hex Code | Usage |
|------|----------|-------|
| Background Base | `#000000` | Main background |
| Surface Dark | `#0A0A0A` | Elevated surfaces |
| Surface Container | `#121212` | Cards, containers |
| Surface Tertiary | `#1A1A1A` | Input fields, buttons |

### Text Colors
| Name | Hex Code | Usage |
|------|----------|-------|
| On Surface | `#FFFFFF` | Primary text |
| On Surface Variant | `#B3B3B3` | Secondary text |
| Muted | `#888888` | Tertiary/hint text |
| Disabled | `#666666` | Disabled states |

---

## 4. ORBITAL ELEMENTS (العناصر المدارية)

### Star Particles
- Color: `#615FFF` with 15% opacity
- Size: 1.5px radius
- Distribution: Random across background
- Animation: Subtle twinkle (optional)

### Connecting Lines
- Color: White with 5-10% opacity
- Stroke: 1px
- Style: Straight lines between orbital elements

### Orbital Ring
- Color: `#615FFF` with 30% opacity
- Stroke: 1px
- Animation: Slow rotation (60 seconds per full rotation)

### Central Profile (Purple Glow System)
- Inner ring: Dark circle with subtle border
- Outer glow: Violet (#8B5CF6) with 15% opacity
- Blur radius: 80px
- Used as visual anchor for orbit system

---

## 5. TYPOGRAPHY (الخطوط)

### Font Stack
```css
font-family: 'Segoe UI', 'SF Arabic', 'Segoe UI Arabic', 'Roboto', sans-serif;
```

### Type Scale

| Style | Size | Weight | Line Height | Letter Spacing |
|-------|------|--------|-------------|----------------|
| Display Large | 72px | Bold | 1.2 | -0.02em |
| Display Medium | 56px | Bold | 1.2 | -0.02em |
| Display Small | 40px | Bold | 1.2 | -0.02em |
| Headline Medium | 32px | SemiBold | 1.25 | -0.02em |
| Headline Small | 24px | SemiBold | 1.25 | -0.02em |
| Title Large | 20px | SemiBold | 1.25 | -0.02em |
| Body Large | 18px | Regular | 1.5 | 0 |
| Body Medium | 16px | Regular | 1.5 | 0 |
| Body Small | 14px | Regular | 1.5 | 0 |
| Label Small | 12px | Medium | 1.2 | 0 |

### Special Typography
- **Logo Text**: 42px, w200, letter-spacing: 6px
- **Taglines**: 10px, w400, letter-spacing: 4px, uppercase

---

## 6. MOTION SYSTEM (نظام الحركة)

### Duration Tokens
| Name | Duration | Usage |
|------|----------|-------|
| Quick | 250ms | Micro-interactions, hovers |
| Standard | 300ms | Default animations |
| Purposeful | 400ms | Page transitions |
| Elaborate | 600ms | Complex animations |
| Page Transition | 350ms | Route changes |

### Easing Curves
| Name | Curve | Usage |
|------|-------|-------|
| Entrance | `Cubic(0, 0, 0.2, 1)` | Elements appearing |
| Exit | `Cubic(0.4, 0, 1, 1)` | Elements disappearing |
| Transition | `Cubic(0.4, 0, 0.2, 1)` | Standard transitions |
| Spring | `elasticOut` | Playful interactions |

### Animation Principles
1. **Staggered Entrance**: Delay increments of 0.1s for lists
2. **Scale on Tap**: 0.95 scale on press, 1.0 on release
3. **Hover Scale**: 1.02 scale on hover (cards)
4. **Fade + Slide**: Combine opacity with 3% Y offset for page transitions

---

## 7. COMPONENT PATTERNS (أنماط المكونات)

### Buttons
```
Primary Button:
- Gradient: #6366F1 → #AB5CF6
- Height: 52px
- Border Radius: 14px
- Text: White, 15px, SemiBold

Secondary Button:
- Background: Transparent
- Border: White 15% opacity
- Height: 52px
- Border Radius: 14px
```

### Cards
```
Standard Card:
- Background: #1C1C2E
- Border: White 10% opacity
- Border Radius: 16px
- Padding: 16px
```

### Input Fields
```
Text Input:
- Background: #1A1A1A
- Border: White 8% opacity (default), Primary color (focused)
- Height: 44-56px
- Border Radius: 12-16px
- Padding: 14-20px horizontal
```

### Filter Chips
```
Unselected:
- Background: #1A1A1A
- Border: White 10% opacity
- Text: White 60% opacity

Selected:
- Background: Section color
- Border: None
- Text: White 100%
```

---

## 8. SPACING SYSTEM (نظام المسافات)

### Base Unit: 4px

| Name | Value | Usage |
|------|-------|-------|
| xs | 4px | Tight spacing |
| sm | 8px | Icon gaps |
| md | 12px | Related elements |
| lg | 16px | Section spacing |
| xl | 20px | Screen padding |
| 2xl | 24px | Major sections |
| 3xl | 32px | Large gaps |

### Screen Padding
- Horizontal: 20-24px
- Top (after safe area): 16px
- Bottom (above nav): 100px

---

## 9. GLOW EFFECTS (تأثيرات التوهج)

### Section Glow
Each section has a characteristic glow:
```dart
BoxShadow(
  color: sectionColor.withOpacity(0.3),
  blurRadius: 12,
  spreadRadius: 2,
)
```

### Central Profile Glow
```dart
BoxShadow(
  color: Color(0xFF615FFF).withOpacity(0.15),
  blurRadius: 80,
  spreadRadius: 20,
)
```

### Icon Glow
```dart
BoxShadow(
  color: iconColor.withOpacity(0.3),
  blurRadius: 12,
  spreadRadius: 2,
)
```

---

## 10. ACCESSIBILITY (إمكانية الوصول)

### Contrast Requirements
- Primary text on dark: Minimum 4.5:1 ratio
- Interactive elements: Clear focus states
- Touch targets: Minimum 48x48px

### RTL Support
- All layouts must support Arabic RTL
- Icons should be mirrored where appropriate
- Text alignment: Start (not left/right)

---

## 11. IMPLEMENTATION CHECKLIST

When implementing any screen:

- [ ] Use official brand colors only
- [ ] Apply correct typography scale
- [ ] Implement orbital elements where appropriate
- [ ] Add section-specific glow effects
- [ ] Use motion tokens for all animations
- [ ] Ensure 20-24px horizontal padding
- [ ] Add UniverseBackButton for navigation
- [ ] Test on dark background (#000000)
- [ ] Verify RTL layout support
- [ ] Match exact Figma specifications

---

## 12. DART COLOR CONSTANTS

```dart
abstract final class UAxisColors {
  static const Color backgroundBase = Color(0xFF000000);
  
  static const Color discoverPremium = Color(0xFF3B82F6);
  static const Color discoverPremiumGlow = Color(0x403B82F6);
  
  static const Color social = Color(0xFFEC4899);
  static const Color socialGlow = Color(0x40EC4899);
  
  static const Color messagesCommerce = Color(0xFF10B981);
  static const Color messagesCommerceGlow = Color(0x4010B981);
  
  static const Color businessAi = Color(0xFF8B5CF6);
  static const Color businessAiGlow = Color(0x408B5CF6);
  
  static const Color aiHub = Color(0xFF06B6D4);
  static const Color aiHubGlow = Color(0x4006B6D4);
  
  static const Color starParticles = Color(0x26615FFF);
  
  static const Color surfaceDark = Color(0xFF0A0A0A);
  static const Color surfaceContainerDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onSurfaceVariantDark = Color(0xFFB3B3B3);
}
```

---

**Last Updated**: January 2026
**Version**: 1.0
**Maintainer**: Senior UI/UX Designer
