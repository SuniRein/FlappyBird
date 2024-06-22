`define WIDTH  640
`define HEIGHT 480

`define PosX wire [9:0]
`define PosY wire [8:0]
`define PosXR reg [9:0]
`define PosYR reg [8:0]

`define GameState wire [1:0]
`define GameStateR reg [1:0]

`define GAME_INIT    2'd0 // 初始化界面
`define GAME_RUNNING 2'd1 // 运行
`define GAME_FAILED  2'd2 // 失败

`define Key wire [7:0]
`define KeyR reg [7:0]

`define NO_KEY    0
`define KEY_UP    1
`define KEY_DOWN  2
`define KEY_LEFT  3
`define KEY_RIGHT 4
`define KEY_SPACE 5

`define Score wire [15:0]
`define ScoreR reg [15:0]
