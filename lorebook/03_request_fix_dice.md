# 🗑️ Request: Fix Dice — 주사위 포맷 수정 규칙

## 항목 정보

| 필드 | 값 |
|------|----|
| **name** | `🗑️ Request: Fix Dice` |
| **type** | `editprocess` |
| **ableFlag** | `true` |

---

## 패턴 (Pattern)

```regex
^<\?checked(.+?)rolled=([\d\s]+)threshold=([{}\d\s]+)(.+?)\?>
```

**플래그**: `smg`

---

## 치환 (Replace)

```
{{#if_pure {{not::{{getglobalvar::toggle_choicemodule_dice}}}}}}<? checked$1success_probability=$3dice_$4?>{{/}}
{{#if_pure {{getglobalvar::toggle_choicemodule_dice}}}}<? checked$1difficulty_class=$3dice_rolled=$2dice_$4?>{{/}}
```

---

## 설명

구형 주사위 포맷(`rolled=`, `threshold=`)을  
현재 모듈이 사용하는 신형 포맷(`success_probability=` 또는 `difficulty_class=`)으로 변환합니다.

- `toggle_choicemodule_dice = 0` (D100): `success_probability=` 포맷으로 변환
- `toggle_choicemodule_dice = 1` (D20): `difficulty_class=`, `dice_rolled=` 포맷으로 변환
- `smg` 플래그: 멀티라인 + 전체 치환
