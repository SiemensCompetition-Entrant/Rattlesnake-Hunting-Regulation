globals [harvest? reproduce? years_passed two_yrs]
breed [snakes snake]
breed [hunters hunter]
snakes-own [snake_length age time reproduce-year]
hunters-own [hunting_season]

to setup
  clear-all
  ask patches
  [
    set pcolor 37           ;; sandy color
  ]


  ;; starting population for adult snakes
  create-snakes round (beginning_snake_number * 0.9)              ;; 90% of starting population will be adult snakes
  [
    set shape "snake"
    set color brown
    setxy random-xcor random-ycor
    set snake_length round random-normal 1118 195       ;; gives our snake length distribution based on raw data
    ifelse snake_length >= 520
    [
      set age round (snake_length / 73)
    ]
    [
     set age round ((snake_length - 228) / 96)          ;; gives a snake's age based on subtracting minimum length (228) from snake length and dividing it by the slope
    ]
    set time 0
    ifelse random 2 = 0                                 ;; set about 50% of the snakes to reproduce this year and 50% to reproduce the next year
    [
      set reproduce-year 0
    ]
    [
      set reproduce-year 1
    ]
    if snake_length >= min_length_of_harvest          ;; if the snake has a length greater than the minimum length of harvest the snake will turn red
    [
     set color red
    ]
  ]

  ;; starting population for baby snakes
  create-snakes round (beginning_snake_number * 0.1)          ;; 10% of starting snake population will be baby snakes
  [
    set shape "snake"
    set color brown                                      ;; brown color
    setxy random-xcor random-ycor
    set snake_length  (228 + random 288)              ;; gives our snake length distribution based on actual data
    set age round ((snake_length - 228) / 96)
    set time 0
    set reproduce-year 0
    if snake_length >= min_length_of_harvest          ;; if the snake has a length greater than the minimum length of harvest the snake will turn red
    [
     set color red
    ]
  ]

  create-hunters hunter_number
  [
    set shape "hunter"
    set size 1
    set color 3                                ;; gray color
    setxy random-xcor random-ycor
  ]

  reset-ticks
end

to go
  move
  reproduction
  harvest
  one-year-of-growth
  update-years
  update-hunting-season
  natural-death
  predator-death
  tick
end

to move
 ask snakes
 [
    right random 50
    left random 50
    forward 1
 ]


  ask hunters
  [
    if hunting_season >= 45 and hunting_season <= 75        ;; allows hunters to move and catch snakes only during hunting season (april - march)
    [
    right random 50
    left random 50
    forward 1
    ]
    ]
end

to reproduction
  ask snakes
  [
   set reproduce? one-of [0 1 2 3]                                            ;; 25% chance reproduction because half of them are female and the females have a 50% chance of reproducing
   if age >= 3 and reproduce? = 1 and reproduce-year = 1 and time = 237       ;; When the snake is sexually mature, the chance of reproducing is yes, two years have passed,
   [                                                                          ;; and the time is Summer (1 time equals 1 day so at 237 days it would be August)
    hatch (5 + random 6)                                                      ;; then the snakes hatch baby snakes between a random number from 5 to 10
   [
    set snake_length  (228 + random 115)                       ;; the baby snake's length is set to a random number from 228 mm
    set age 0                                                  ;; to 343 mm (based on research newborn snakes avg 9-13.5 inches or around 228 mm to 343 mm)
    set reproduce-year 0
    set color brown
   ]
   ]
  ]
end

to harvest
  ask hunters
  [
    if ( count snakes-here with [color = red] > 0 ) and ( hunting_season >= 45 and hunting_season <= 75 )         ;; if the snake is red and it is hunting season the snake will be "captured"
    [
     let temp-counter 0
     let temp-pop count ( snakes-here with [color = red] )
     while [(temp-counter < temp-pop) and (count snakes-here with [color = red] > 0) ]               ;; adds the total number of snakes on the patch to the number of snakes harvested. It's done by creating a while loop that repeatedly
     [                                                                                               ;; adds 1 to the amount of snakes harvested until the temp-counter is equal to the number of snakes on the patch (temp-pop).
     if random 1000 <= 70                                                                            ;; based on calculations, there is a .007 chance of a hunter finding a snake in a 1 mi square area
     [
      ask one-of snakes-here with [color = red]
      [
       set harvest? harvest? + 1
       die
      ]
       ]
     set temp-counter temp-counter + 1
     ]
    ]
  ]
end

to one-year-of-growth
 ask snakes                                         ;; has the snakes grow older and longer based on whether the time is equal to 365 (365 time is equal to 1 year)
  [
   set time time + 1
   if time >= 365
   [
    set age age + 1
    set snake_length snake_length + 77               ;; snake grows 88 mm per year based on calculations from data
    set time 0
    set reproduce-year  1
    if snake_length >= min_length_of_harvest          ;; if the snake has a length greater than the minimum length of harvest the snake will turn red
    [
     set color red
    ]
   ]
  ]
end

to update-years
  set years_passed ticks / 365                        ;; tells how many years have gone by
end

to update-hunting-season
  ask hunters
  [
   set hunting_season hunting_season + 1              ;; keeps track of hunting season (1 hunting season equals 1 day)
   if hunting_season >= 365
   [
    set hunting_season 0                              ;; once it reaches 1 year (365 days) it resets to zero
   ]
  ]
end

to natural-death
  ask snakes
  [
   if age >= 20
   [
    if (70 + age) > random 100                       ;; when the snake reaches 20 yrs old, they have a 90 percent chance of dying. As they get older, the chances of death increase
    [
     die
    ]
   ]
  ]
end

to predator-death
  ask snakes
  [
   if random 712 = 0                  ;; 1 percent chance of dying for per two-year period
   [
    die
   ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
254
20
804
501
-1
-1
45.0
1
10
1
1
1
0
1
1
1
0
11
0
9
1
1
1
ticks
30.0

BUTTON
50
64
114
97
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
122
64
185
97
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
19
120
223
153
beginning_snake_number
beginning_snake_number
0
7200
7200
100
1
NIL
HORIZONTAL

SLIDER
19
161
222
194
hunter_number
hunter_number
0
30
3
1
1
NIL
HORIZONTAL

MONITOR
23
274
121
319
Snake Population
count snakes
17
1
11

SLIDER
19
203
222
236
min_length_of_harvest
min_length_of_harvest
0
2000
300
100
1
NIL
HORIZONTAL

MONITOR
47
328
198
373
Number of Snakes Harvested
harvest?
1
1
11

MONITOR
134
274
221
319
Years Passed
years_passed
1
1
11

PLOT
899
29
1213
231
Snake Population
ticks
number of snakes
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"snakes" 1.0 0 -8431303 true "" "plot count snakes"

PLOT
901
281
1181
467
Snake Length Distribution
NIL
NIL
0.0
2000.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -8431303 true "set-histogram-num-bars 20\nset-plot-pen-interval 100" "if (plot-histogram? and (ticks mod 10 = 0)) [\n   histogram [snake_length] of snakes\n]"

SWITCH
47
399
188
432
plot-histogram?
plot-histogram?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

This model was created in order to observe the impact of rattlesnake hunting on the population of rattlesnakes in the Southwest corner of Chaves County, New Mexico, where it was determined was the center of where the majority of rattlesnakes came from. This model looks at three initial variables: initial number of rattlesnakes, initial number of hunters, and minimum snake length requirement for hunters to be able to keep a rattlesnake they catch.

## CREDITS AND REFERENCES

Raw data gathered by the late New Mexico State Herpetologist
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

hunter
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -6459832 true false 90 45 225 45 195 30 180 0 120 0 105 30 75 45

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

snake
false
0
Polygon -7500403 true true 300 135 300 165 270 180 255 165 240 165 225 180 195 195 180 195 150 180 135 165 120 135 105 120 75 105 45 105 30 120 15 135 0 165 15 105 45 75 90 75 120 90 150 120 165 150 180 165 195 165 225 150 240 135 255 135 270 120

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="40" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="snake_number">
      <value value="72000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="min_length_of_harvest" first="100" step="100" last="1700"/>
    <enumeratedValueSet variable="hunter_number">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="trial test - harvest" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="21900"/>
    <metric>count snakes</metric>
    <metric>harvest?</metric>
    <steppedValueSet variable="hunter_number" first="0" step="2" last="30"/>
    <enumeratedValueSet variable="plot-histogram?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="min_length_of_harvest" first="200" step="200" last="1600"/>
    <enumeratedValueSet variable="beginning_snake_number">
      <value value="7200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="trial test 1 short" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>count snakes</metric>
    <steppedValueSet variable="hunter_number" first="0" step="1" last="3"/>
    <enumeratedValueSet variable="plot-histogram?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="min_length_of_harvest" first="200" step="100" last="300"/>
    <enumeratedValueSet variable="beginning_snake_number">
      <value value="72000"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
