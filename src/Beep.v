module Beep(
    input      clk,
    output reg beep
);

reg [31:0] x,y,k;
reg [31:0] a [0:15];
wire [3:0] b;

SongROM song_rom(
    .clka  (clk),
    .ena   (1'b1),
    .addra (k[7:0]),
    .douta (b)
);

initial begin
    x=1;y=1;k=0;
    a[0]=50000000/415;
    a[1]=50000000/440;
    a[2]=50000000/494;
    a[3]=50000000/523;
    a[4]=50000000/587;
    a[5]=50000000/659;
    a[6]=50000000/698;
    a[7]=50000000/784;
    a[8]=50000000/880;
    a[9]=50000000/988;
    a[10]=50000000/1046;
    a[15]=50000000/392;
end
always@(posedge clk)begin
    x=x+1;
    y=y+1;
    if(x==25000000)begin
        k=k+1;x=0;y=0;
    end
    if(k==256)k=0;
    if(y==a[b])y=0;
    if(y*2<a[b])beep=1;
    else beep=0;
end

endmodule
