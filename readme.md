# 简介

本设计是运用 Verilog 语言，使用 Vivado 在 Xillix 开发板上实现的 FlappyBird 小游戏。

该项目仅为学生的课程作业，**玩具所作**。
限于对 Verilog 语言的不熟悉，及开发时间有限，项目中存在很多缺陷，请勿直接使用。

# 模块介绍

## 项目架构分析

可将项目中的各个模块划分为**游戏逻辑模块**和**外设模块**（包括VGA、键盘、蜂鸣器、LED、数码管等）。

游戏的逻辑模块由以下几部分构成：

- 随机数生成（`Ramdom32.v`)

- 小鸟飞行、渲染逻辑（`Bird.v`）

- 柱子生成、移动和渲染逻辑（`Pillar.v`）

- 游戏状态变化（`GameStateUnit.v`）

以下是各个模块的具体分析。

## 时钟分频器

考虑到在项目中需要不同频率的始终信号，创建了这样一个模块化的时钟分频器，定义在`ClockDiv.v`中。

```verilog
module ClockDiv
#(
    parameter INPUT_CLOCK_FLUENCY  = 100_000_000, // 100 MHz
    parameter OUTPUT_CLOCK_FLUENCY =  50_000_000  //  50 MHz
)(
    input clk,
    input rstn,

    output reg clk_div
);
```

该模块接受输入时钟频率和输出时钟频率两个模板参数，输出对应频率的时钟信号。

在整个项目中，使用该模块生成了 VGA 显示器所需要的 25MHz 的时钟和游戏的帧时钟（50Hz）。

## 小鸟模块

关于小鸟的移动、飞行等信息的处理定义在`Bird.v`文件中。

```verilog
module Bird
#(
    parameter BIRD_X      = 0,
    parameter BIRD_Y_INIT = 240,
    parameter BIRD_WIDTH  = 40,
    parameter BIRD_HEIGHT = 45,
    parameter BIRD_UP     = 3,
    parameter BIRD_DOWN   = 3,
    parameter BIRD_FALL   = 2
)(
    input            clk,
    input            rstn,
    input            frame_clk,
    input `GameState state,
    input            up,
    input            down,
    input `PosX      x,
    input `PosY      y,
    input            no_fall, // 使鸟不要掉落，方便调试

    output            out_of_bound,
    output reg        valid,
    output reg [11:0] color
);
```

小鸟的水平位置是固定的，我们**只保存小鸟的竖直位置**。这里的位置指的是小鸟**左上角**的坐标。

`frame_clk`是游戏的**帧时钟**，频率为50Hz，用于事件处理。
在每个帧时钟正边沿，根据游戏状态`state`和输入的控制信号`up`，`down`进行判断。
如果当前游戏正在运行，就进行事件处理，移动小鸟的坐标。否则，初始化鸟的坐标为给定值`BIRD_Y_INIT`。

```verilog
always @(posedge frame_clk, negedge rstn) begin
    if (!rstn) begin
        bird_y <= BIRD_Y_INIT;
    end
    else if (state == `GAME_RUNNING) begin
             if (up)      bird_y <= bird_y - BIRD_UP;
        else if (down)    bird_y <= bird_y + BIRD_DOWN;
        else if (no_fall) bird_y <= bird_y;
        else              bird_y <= bird_y + BIRD_FALL;
    end
    else begin
        bird_y <= BIRD_Y_INIT;
    end
end
```

`x`、`y`为**当前 VGA 扫描信号所对应坐标**。
我们判断这个坐标是否为小鸟的位置坐标，然后从 ROM 中读取相应位置的颜色并输出。

因为图片是方形的，而**鸟的形状是不规则的**，所以我们在图片处理时，
将不属于鸟的部分用某种颜色`INVALID_COLOR`标记，并在读取时进行判断，从而渲染出了不规则形状的鸟。
如果当前位置确实是鸟的有效部分，我们就设置`valid`为1，作为输出信号。

`out_of_bound`则是对鸟坐标进行实时判断，用于**检测鸟是否飞越地图边界**。

在 Top 模块中小鸟的定义如下：

```verilog
Bird #(
    .BIRD_X      (100),
    .BIRD_Y_INIT (240),
    .BIRD_WIDTH  (40),
    .BIRD_HEIGHT (30),
    .BIRD_UP     (8),
    .BIRD_DOWN   (10),
    .BIRD_FALL   (3)
) bird (
    .clk          (clk),
    .rstn         (rstn),
    .frame_clk    (frame_clk),
    .state        (state),
    .up           (key_up || key_space),
    .down         (key_down),
    .x            (curr_x),
    .y            (curr_y),
    .no_fall      (bird_no_fall),
    .out_of_bound (out_of_bound),
    .valid        (is_bird),
    .color        (bird_color)
);
```

特别指出，可以使用键盘上的上、下键来操纵小鸟的移动，但这只是**为了调试方便**，游戏在实际运行中是使用空格进行操作。

## 柱子模块

柱子的生成、移动、渲染等逻辑定义在`Pillar.v`文件中。
我们用数组来存储所有柱子的x、y坐标。这些坐标对应**柱子上半部分的右下角**。

```verilog
module Pillar
#(
    parameter PILLAR_COUNT       = 5,
    parameter BIRD_X             = 100,
    parameter PILLAR_X_INIT      = 320,
    parameter PILLAR_Y_MIN       = 100,
    parameter PILLAR_X_WIDTH     = 50,
    parameter PILLAR_Y_WIDTH     = 100,
    parameter PILLAR_HEAD_HEIGHT = 30,
    parameter PILLAR_GAP         = 100,
    parameter PILLAR_SPEED       = 1
)(
    input             clk,
    input             rstn,
    input             frame_clk,
    input `GameState  state,
    input `PosX       x,
    input `PosY       y,
    input             no_move,
    output reg        valid,
    output reg [11:0] color,
    output `ScoreR    score
);
```

柱子模块的整体架构与小鸟相似，不同的是我们有不止一根柱子，柱子具有两个坐标，且柱子的贴图构成更复杂。

```verilog
`GAME_RUNNING: begin
    for (i = 0; i != PILLAR_COUNT; i = i + 1) begin
        if (pillar_x[i] <= BIRD_X && !passed[i]) begin
            running_score <= running_score + 1;
            pillar_x[i]   <= (no_move) ? pillar_x[i] : pillar_x[i] - PILLAR_SPEED;
            pillar_y[i]   <= pillar_y[i];
            passed[i]     <= 1'b1;
        end
        else begin
            if (pillar_x[i] <= PILLAR_SPEED) begin // 柱子越界，销毁，重新生成
                pillar_x[i] <= pillar_x[(i==0)?(PILLAR_COUNT-1):(i-1)] + PILLAR_GAP;
                pillar_y[i] <= PILLAR_Y_MIN + random_pos;
                passed[i]   <= 1'b0;
            end
            else begin
                pillar_x[i] <= (no_move) ? pillar_x[i] : pillar_x[i] - PILLAR_SPEED;
                pillar_y[i] <= pillar_y[i];
                passed[i]   <= passed[i];
            end
        end
    end
    score <= running_score;
end
```

在事件逻辑中，我们使用 for 循环**对每根柱子进行单独判断**。
如果**小鸟越过了当前的柱子**，我们就将积分加一。
如果检测到**柱子越过边界**，我们就将柱子销毁，并在当前最后一根柱子的基础上生成下一根柱子。
注意，在计分时我们操作了`running_score`而不直接操纵`score`，是为了**在游戏结束时保存得分，防止分数被清零**。

柱子的渲染部分与小鸟很相似，不同点在于我们需要对每根柱子都进行判断，同时还需要**判断柱子所属的部分**。
我们的柱子由柱子头部和柱子主体两部分构成，它们的渲染逻辑不一样，所以需要分开处理。
最后按照我们得到的信息，从 ROM 中读取相应的颜色并输出。
虽然柱子是方形的，但**柱子主体比柱子头部要窄一些**，为了方便，我们同样采用了`INVALID_COLOR`的技巧。

当游戏结束时，我们会**对所有柱子进行初始化**。
需要注意的是，由于初始化是**在一个时钟周期内完成的**，来不及输出不同的随机数，
所以所有的柱子的竖直坐标都是相同的，在游戏中会表现为**游戏开始时的前四根柱子有相同的高度**，这算是游戏的一个bug。

在 Top 模块中柱子的定义如下：

```verilog
Pillar #(
    .PILLAR_COUNT       (4),
    .BIRD_X             (100),
    .PILLAR_X_INIT      (250),
    .PILLAR_X_WIDTH     (60),
    .PILLAR_Y_WIDTH     (150),
    .PILLAR_Y_MIN       (101), // 101*2 + 128 + 150 = 480
    .PILLAR_HEAD_HEIGHT (30),
    .PILLAR_GAP         (180),
    .PILLAR_SPEED       (1)
) pillars (
    .clk       (clk),
    .rstn      (rstn),
    .frame_clk (frame_clk),
    .state     (state),
    .x         (curr_x),
    .y         (curr_y),
    .no_move   (pillars_no_move),
    .valid     (is_pillar),
    .color     (pillar_color),
    .score     (score)
);
```

这里设置柱子的`PILLAR_Y_MIN`为 101 是为了使柱子高度的可调控范围恰好为 128，为 **2 的幂次**，便于随机数生成。

## 随机数的生成

在进行柱子坐标的生成时需要用到随机数，其生成引擎定义在`Random32.v`中。

```verilog
module Random32(
    input        clk,
    input        rstn,
    input [31:0] seed,

    output [31:0] number
);

reg [31:0] rand32;

always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
        rand32 <= seed;
    end
    else begin
        rand32 <= rand32 ^ (rand32 << 13) ^ (rand32 >> 17) ^ (rand32 << 5);
    end
end

assign number = rand32;

endmodule
```

这里使用到了 **xorshift 算法**来生成随机数，这是一种简单高效的随机数算法，只需通过简单的异或和移位操作即可生成良好的随机数。

我们生成的随机数有 32 位，实际只取它的最低 7 位。

## 游戏状态转移逻辑

我们的游戏有三种状态：Init、Running 和 Failed，状态转移逻辑定义在`GameStateUnit.v`中。

```verilog
module GameStateUnit(
    input clk,
    input rstn,
    input start,
    input failed,
    output `GameStateR state
);
```

该模块接受两个操作信号，输出对应的游戏状态。其在 Top 模块中的定义如下：

```
`GameState state;
wire failed = !bird_no_die && (is_collision || out_of_bound);

GameStateUnit game_state_unit(
    .clk    (clk),
    .rstn   (rstn),
    .start  (key_space_press_once),
    .failed (failed),
    .state  (state)
);
```

当按下空格是，激活`start`信号；当`bird_no_die`模式没有启动，且发生碰撞或地图越界时，激活`failed`信号。

**碰撞检测**则是依靠判断当前渲染位置是否同时为小鸟和柱子来实现的。由于 VGA 时钟频率足够高，其准确性可以保证。

## VGA 驱动模块

VGA 驱动模块定义在`VgaDriver.v`中。

关于模块的具体细节，可参考[FPGA零基础学习：VGA协议驱动设计](https://zhuanlan.zhihu.com/p/359125055)。

`curr_x`和`curr_y`实际上输出下一待渲染位置的坐标

```verilog
module VgaDriver(
    input        clk, // 25.175 MHz
    input        rstn,
    input [11:0] color, // bbbb_gggg_rrrr

    output `PosXR    curr_x,
    output `PosYR    curr_y,
    output reg [3:0] r, g, b,
    output reg       rdyn,
    output           hs, vs // 行同步信号和场同步信号
);
```

## 键盘驱动模块

键盘驱动模块定义在`Keyboard.v`中。

该模块的实现细节可参考[一天一个设计实例-FPGA和PS/2键盘](https://zhuanlan.zhihu.com/p/384221079)。

```verilog
module Keyboard(
    input        clk,
    input        rstn,
    input        PS2_clk,
    input        PS2_data,
    output `KeyR key,
    output reg   key_state
);
```

## 灯光显示

本项目中还使用到了 LED 和数码管输出模块，包含在`LEDs`文件夹中。
其中 LED 灯用来输出一些调试信息，数码管则用来进行分数显示。

在显示十进制分数时为了方便，我们直接使用了**昂贵的整除和取余操作**，不过这部分并不算庞大，其代价在可接受范围。
实际可以使用其他方法来规避这种代价。

## 蜂鸣器

蜂鸣器定义在Beep.v中，用来输出游戏的背景音乐。

```verilog
module Beep(
    input      clk,
    output reg beep
);
```

当输出`beep`为 1 时，蜂鸣器响，否则蜂鸣器不响。
我们只要让`beep`输出特定频率的方波，蜂鸣器就能发出特定频率的音符。
我们规定一个音符的长度是 0.5s，也就是 50000000 个时钟周期，然后把乐谱写入 ROM 中。
播放音乐时，蜂鸣器每隔 0.5s 就会读取下一个音符，这样就能播放完整的音乐了。
我们还设计了关闭音乐的功能，只需关闭音乐开关，`beep`就会恒为 0，这样蜂鸣器就不会发声了。

## ROM
项目中需要用到 ROM 来存储相关图片的颜色信息，这里我们使用[CoeConverter](https://github.com/thu-cs-lab/CoeConverter)
将图片处理为 coe 文件后，在 verilog 中调用 IP 核来构造相应的ROM。

# 仿真与调试

项目用到的仿真文件包括在`tb`文件夹中，包含了对`ClockDiv`、`Pillar`、`Keyboard`、`Random32`、`VgaDriver`等的简单仿真。

由于项目中很多东西**需要与外界进行交互**，如 VGA 的输出，键盘的输出等，**不方便直接仿真**，大多数时候采用直接下板的方式来进行调试。
在这过程中也使用到了一些方便调试的东西，如用开关来控制`bird_no_die`、`bird_no_fall`、`pillar_no_move`等调试信号，便于观察相应的行为；
使用键盘上的上下键来控制小鸟的移动；也使用了 LED 灯来输出一些相关信息，如LED的前五个位置分别对应键盘的上下左右方向键和空格键，
在按下相应按键时会熄灭，而最后一个位置在发生碰撞时会闪烁。

## 参考工程

[FlappyGhost](https://github.com/acyanbird/flappyGhost)
