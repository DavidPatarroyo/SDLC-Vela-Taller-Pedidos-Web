# Plantilla · Skill

> Copia el bloque de abajo en `.claude/skills/documentar-modulo/SKILL.md` (crea las carpetas)
> y reemplaza cada `[…]`. Las tres rayas `---` van en la primera línea del archivo.
> Si la description tiene dos puntos (`:`), déjala entre comillas, como en el ejemplo.

```markdown
---
name: documentar-modulo
description: "[Qué hace, en una frase]. Úsala cuando [en qué situaciones], aunque no nombren la Skill."
---

# Documentar un módulo

## Pasos
1. […]
2. […]
3. […]

## Qué debe tener docs/modulos/<Modulo>.md
- Propósito
- API pública
- Ejemplo de uso
- Diagrama Mermaid

## Reglas
- […]
```

**La clave está en la description:** di qué hace y cuándo usarla. Claude decide si usa tu Skill solo por esa frase.
