module elevator_module_tb;

  // Parameters
  parameter N = 5;
  parameter board_freq = 10;
  parameter module_freq = 1;
  parameter door_open_time = 10;

  // Inputs
  reg [N:1] request_up_button;
  reg [N:1] request_down_button;
  reg close_button;
  reg open_button;
  reg [N:1] input_floor_button;
  reg board_clk;

  // Outputs
  wire door_led;
  wire go_up_led;
  wire go_down_led;
  wire [N:1] led_up;
  wire [N:1] led_down;
  wire seg_a;
  wire seg_b;
  wire seg_c;
  wire seg_d;
  wire seg_e;
  wire seg_f;
  wire seg_g;

  // Instantiate the Unit Under Test (UUT)
  elevator_module #(N, board_freq, module_freq, door_open_time) uut (
    .request_up_button(request_up_button),
    .request_down_button(request_down_button),
    .close_button(close_button),
    .open_button(open_button),
    .input_floor_button(input_floor_button),
    .board_clk(board_clk),
    .door_led(door_led),
    .go_up_led(go_up_led),
    .go_down_led(go_down_led),
    .led_up(led_up),
    .led_down(led_down),
    .seg_a(seg_a),
    .seg_b(seg_b),
    .seg_c(seg_c),
    .seg_d(seg_d),
    .seg_e(seg_e),
    .seg_f(seg_f),
    .seg_g(seg_g)
  );

  // Clock generation
  initial
  begin
    board_clk = 0;
    forever #10 board_clk = ~board_clk; // 50 MHz clock generation
  end

  // Test sequence
  initial
  begin
    // Reset all inputs
    request_up_button = 5'b00000;
    request_down_button = 5'b00000;
    close_button = 0;
    open_button = 0;
    input_floor_button = 5'b00000;

    #50; // Wait for 50 time units

    // Test Case 1: Request to go up from floor 1
    request_up_button[1] = 1;
    #100;
    request_up_button[1] = 0;

    // Test Case 2: Select floor 3 from inside the elevator (at floor 1)
    input_floor_button[3] = 1;
    #100;
    input_floor_button[3] = 0;

    // Test Case 3: Request to go down from floor 4
    #300; // Wait until elevator reaches floor 3
    request_down_button[4] = 1;
    #100;
    request_down_button[4] = 0;

    // Test Case 4: Request to go up from floor 5
    #500; // Wait until elevator reaches floor 4
    request_up_button[5] = 1;
    #100;
    request_up_button[5] = 0;

    // Test Case 5: Open and close door manually at floor 5
    #300;
    open_button = 1;
    #100;
    open_button = 0;
    #200;
    close_button = 1;
    #100;
    close_button = 0;

    // Test Case 6: Select floor 1 from inside the elevator (at floor 5)
    input_floor_button[1] = 1;
    #100;
    input_floor_button[1] = 0;

    // Wait for elevator to return to floor 1
    #1000;
    $stop; // End the simulation
  end

endmodule
