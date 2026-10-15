`timescale 1ns / 1ps

module My_Top_Module (
    input clk,
    input btnU,
    input [15:0] sw,
    output [7:0] JB
);

    wire slowclk;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    wire [15:0] oled_data;
    wire [15:0] background_colour;
    // SW4 ON: red. SW4 OFF: green.
    assign background_colour = sw[4] ? 16'hF800 : 16'h07E0;
    //bg colour

    // Hold reset to btnU
    wire resetdisplay = btnU;
    reg [3:0] reset_count = 4'd0;
    



wire [15:0] after_rectangle1;
wire [15:0] after_circle1;
// First rectangle: red, over your existing background.
rectangle rectangle1 (
    .pixel_index       (pixel_index),
    .leftx             (7'd10),
    .rightx            (7'd35),
    .upy               (6'd10),
    .downy             (6'd25),
    .colour            (16'h1F),
    .background_colour (background_colour),
    .oled_data         (after_rectangle1)
);

// Second rectangle: green, over the first rectangle's output.
rectangle rectangle2 (
    .pixel_index       (pixel_index),
    .leftx             (7'd25),
    .rightx            (7'd55),
    .upy               (6'd20),
    .downy             (6'd40),
    .colour            (16'h07E0),
    .background_colour (after_rectangle1),
    .oled_data         (oled_data)
);

circle circle1 (
    .pixel_index       (pixel_index),
    .centrex           (7'd48),
    .centrey           (6'd32),
    .radius            (7'd10),
    .colour            (16'hFE19), // Pink: RGB565
    .background_colour (oled_data),
    .oled_data         (after_circle1)
);



    // Must produce 6.25 MHz from the board's 100 MHz clock.
    clock_divider newclk (
        .clk(clk),
        .clk_out(slowclk)
    );

    Oled_Display oled (
        .clk(slowclk),
        .reset(resetdisplay),
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(after_circle1),

        .cs(JB[0]),
        .sdin(JB[1]),
        .sclk(JB[3]),
        .d_cn(JB[4]),
        .resn(JB[5]),
        .vccen(JB[6]),
        .pmoden(JB[7])
    );

    assign JB[2] = 1'b0;

endmodule