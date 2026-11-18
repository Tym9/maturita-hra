# LEVEL boss — Reactor Warden arena (Sál reaktoru)

One closed single-screen room behind the reactor door (end of c7). The whole fight is visible at once. Floor and ceiling are both flat and safe: in phase 2 the Warden flips the arena's gravity and the fight moves to the ceiling. Two iron catwalks give a second height. `A` = the Warden (hovers; its origin is the core).

```layout
chapter res://boss_room.tscn
start_items wrench gravity_coil grapple_hook
c7_boss 0 0
```

## Rooms (ASCII)

### c7_boss — the reactor hall
```
   01234567890123456789
10 BBBBBBBBBBBBBBBBBBBB
 9 BBBBBBBBBBBBBBBBBBBB
 8 &zzzzzzzzzzzzzzzzzz&
 7 &zzozzzzzzzzzzzzozz&
 6 &zzzzzzzzzAzzzzzzzz&
 5 &zzzzzzzzzzzzzzzzzz&
 4 &zzZZZZzzzzzzZZZZzz&
 3 &zzzzzzzzzzzzzzzzzz&
 2 &zzzzzzzzzzzzzzzzzz&
 1 &z@zzzzzzzzzzzzzzzz&
 0 BBBBBBBBBBBBBBBBBBBB
```
```props
room checkpoint = true
```
