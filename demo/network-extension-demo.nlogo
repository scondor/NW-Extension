extensions [ network nw ]

directed-link-breed [ dirlinks dirlink ]
undirected-link-breed [ unlinks unlink ]

globals [
  subgraphs
  highlighted-subgraph
]

to-report get-link-breed
  report ifelse-value directed
    [ dirlinks ]
    [ unlinks ]
end

to-report get-links-to-use
  report ifelse-value (links-to-use = "directed")
    [ dirlinks ]
    [ ifelse-value (links-to-use = "undirected")
      [ unlinks ] 
      [ links ] 
    ]
end

to radial
  layout-radial turtles links (max-one-of turtles [ count my-links ] )
end

to spring
  layout-spring turtles links spring-constant spring-length repulsion-constant
end

to circle
  layout-circle sort turtles 8
end

to tutte
  layout-circle sort turtles 10
  repeat 10 [
    layout-tutte max-n-of (count turtles * 0.5) turtles [ count my-links ] links 12
  ]
end

to clear
  clear-all
  set-current-plot "Degree distribution"
  set subgraphs []
  set-default-shape turtles "circle"
end

; Clusterers -------------------------------------

to color-clusters [ clusters ]
  let n length clusters
  let colors ifelse-value (n < 14)
    [ n-of n remove gray base-colors ]
    [ n-values n [ random 140 ] ]
  
    (foreach clusters colors [
      let c ?2
      foreach ?1 [ ask ? [ set color c ] ]
    ])
end

to k-means
  nw:set-snapshot turtles get-links-to-use
  let clusters nw:k-means-clusters nb-clusters 1000 0.001
  if length clusters > 0 [ color-clusters clusters ]
end   

to next-subgraph
  if highlighted-subgraph >= length subgraphs
    [ set highlighted-subgraph 0 ]
  highlight-subgraph-number highlighted-subgraph
end

to highlight-subgraph [ subgraph ]
  ask turtles [ set color gray - 3 ]
  ask links [ set color gray - 3 ]
  ask turtle-set subgraph [ 
    set color yellow 
    ask my-links [
      if member? other-end subgraph [
        set color white
      ]
    ]
  ]
end

to highlight-subgraph-number [ i ]
  if length subgraphs > 0 [
    set highlighted-subgraph i + 1
    highlight-subgraph item i subgraphs
  ]
end

to bicomponent
  nw:set-snapshot turtles get-links-to-use
  set subgraphs nw:bicomponent-clusters
  highlight-subgraph-number 0
end

to find-cliques
  nw:set-snapshot turtles get-links-to-use
  set subgraphs nw:maximal-cliques
  highlight-subgraph-number 0
end

to find-biggest-clique
  nw:set-snapshot turtles get-links-to-use
  highlight-subgraph nw:biggest-maximal-clique
end

to weak-component
  nw:set-snapshot turtles get-links-to-use
  color-clusters nw:weak-component-clusters
end

; Centrality --------------------------------------

to centrality [ measure ]
  nw:set-snapshot turtles get-links-to-use
  ask turtles [
    let res (runresult measure)
    set label precision res 2
    set size res
  ]
end

to betweenness
  centrality task nw:betweenness-centrality
end

to eigenvector
  centrality task nw:eigenvector-centrality
end

to closeness
  centrality task nw:closeness-centrality
end

; Generators --------------------------------------

to preferential-attachment
  nw:generate-preferential-attachment turtles get-link-breed nb-nodes []
  update-plots
end

to ring
  nw:generate-ring turtles get-link-breed nb-nodes []
  update-plots
end  

to star
  nw:generate-star turtles get-link-breed nb-nodes []
  update-plots
end  

to wheel
  if directed and wheel-inward [ nw:generate-wheel-inward turtles get-link-breed nb-nodes [] ]
  if directed and not wheel-inward [ nw:generate-wheel-outward turtles get-link-breed nb-nodes [] ]
  if not directed [ nw:generate-wheel turtles get-link-breed nb-nodes [] ]
  update-plots
end  

to lattice-2d
  nw:generate-lattice-2d turtles get-link-breed nb-rows nb-cols wrap []
  update-plots
end

to small-world
  nw:generate-small-world turtles get-link-breed nb-rows-sw nb-cols-sw clustering-exp is-toroidal []
  update-plots
end

to generate-random
  nw:generate-random turtles get-link-breed nb-nodes-er connexion-prob []
  update-plots
end

; Save / Load -----------------------------------------------
to save
  nw:set-snapshot turtles get-links-to-use
  nw:save-matrix "matrix.txt"
end

to load
  nw:load-matrix "matrix.txt" turtles get-link-breed
end

to mean-link-path-length
  nw:set-snapshot turtles links
  user-message nw:mean-link-path-length
end
@#$#@#$#@
GRAPHICS-WINDOW
645
90
1258
724
16
16
18.3
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
245
370
425
403
NIL
betweenness
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
245
135
395
153
Clusterers
12
0.0
1

BUTTON
245
160
315
193
NIL
k-means
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
400
10
470
43
NIL
spring
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
315
10
395
43
NIL
circle
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
475
10
625
43
spring-constant
spring-constant
0
0.5
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
630
10
755
43
spring-length
spring-length
1
10
2
0.5
1
NIL
HORIZONTAL

SLIDER
760
10
920
43
repulsion-constant
repulsion-constant
0
10
2
0.5
1
NIL
HORIZONTAL

SLIDER
10
110
210
143
nb-nodes
nb-nodes
0
1000
20
1
1
NIL
HORIZONTAL

SLIDER
315
160
425
193
nb-clusters
nb-clusters
2
14
4
1
1
NIL
HORIZONTAL

TEXTBOX
245
345
395
363
Centrality
12
0.0
1

BUTTON
435
300
615
333
NIL
bicomponent
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
555
250
615
295
nb
length subgraphs
17
1
11

BUTTON
10
10
90
43
NIL
clear
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
10
145
212
178
NIL
preferential-attachment
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
10
390
110
423
NIL
lattice-2d
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
355
110
388
nb-rows
nb-rows
0
20
2
1
1
NIL
HORIZONTAL

SLIDER
110
355
210
388
nb-cols
nb-cols
0
20
2
1
1
NIL
HORIZONTAL

SWITCH
110
390
210
423
wrap
wrap
1
1
-1000

TEXTBOX
10
70
160
88
Generators
12
0.0
1

BUTTON
245
405
425
438
NIL
eigenvector
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
10
525
210
558
random
generate-random
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
490
210
523
nb-nodes-er
nb-nodes-er
0
100
2
1
1
NIL
HORIZONTAL

SLIDER
10
455
210
488
connexion-prob
connexion-prob
0
1
1
0.01
1
NIL
HORIZONTAL

BUTTON
10
675
210
708
NIL
small-world
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
570
102
603
nb-rows-sw
nb-rows-sw
0
100
4
1
1
NIL
HORIZONTAL

SLIDER
105
570
210
603
nb-cols-sw
nb-cols-sw
0
100
3
1
1
NIL
HORIZONTAL

SLIDER
10
605
210
638
clustering-exp
clustering-exp
0
10
0.3
0.1
1
NIL
HORIZONTAL

SWITCH
10
640
210
673
is-toroidal
is-toroidal
1
1
-1000

BUTTON
245
440
425
473
NIL
closeness
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
90
70
207
103
directed
directed
0
1
-1000

BUTTON
95
10
150
43
size 1
ask turtles [ set size 1 ]
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
155
10
225
43
size * 2
ask turtles [ set size size * 2 ]
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
230
10
300
43
size / 2
ask turtles [ set size size / 2 ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
495
250
552
295
current
highlighted-subgraph
17
1
11

BUTTON
435
250
490
295
next
next-subgraph
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
245
300
425
333
NIL
weak-component
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
245
70
425
115
links-to-use
links-to-use
"all links" "undirected" "directed"
1

BUTTON
935
10
1007
43
radial
radial
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
245
485
425
620
Degree distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [ count my-links ] of turtles"

BUTTON
1015
10
1082
43
NIL
tutte
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
245
675
335
708
NIL
save
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
340
675
425
708
NIL
load
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
245
625
335
670
NIL
count turtles
17
1
11

MONITOR
340
625
425
670
NIL
count links
17
1
11

BUTTON
435
205
615
238
maximal cliques
find-cliques
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
435
170
615
203
NIL
find-biggest-clique
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
435
370
615
403
NIL
mean-link-path-length
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
10
180
210
213
NIL
ring
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
10
215
70
248
NIL
wheel
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
75
215
210
248
wheel-inward
wheel-inward
0
1
-1000

BUTTON
10
260
73
293
NIL
star
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
1
@#$#@#$#@