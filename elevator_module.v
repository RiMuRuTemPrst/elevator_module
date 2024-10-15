// DE2 -- 115
module elevator_module
  #(parameter N = 5, //Number of floors
    parameter board_freq = 50000000, //Freq of FPGA (50 MGhz)
    parameter module_freq = 1, //Freq of Module (1 Hz)
    parameter door_open_time = 10 
    )
    ( 
    input [N:1] request_up_button, //Button up outside the elevator// 1- 5: SW17 - SW 13
    input [N:1] request_down_button, //Button down outside the elevator: 1-5: SW12 - SW 8
    input close_button,              //Button Close the Door inside the elevavtor   SW1
    input open_button,               //Button Open the Door inside the elevator SW2
    input [N:1] input_floor_button,   //Choose Floor inside the elevator// 1-5:    SW7 - SW3
    input board_clk,                  //Freq of FPGA    

    output reg door_led,    // 0 = close, 1 = open  // LED G7
    output reg go_up_led,   // =1 when up_direction = 1;    // LEDR1
    output reg go_down_led, // =1 when down_direction = 1;  // LEDR0
    output reg [N:1] led_up,    //Led outside the elevator each floor// 1-5: LEDR17 - LEDR13
    output reg [N:1] led_down, // Led outside the elevator each floor// 1-5: LEDR12- LEDR8
    
    //Led Current Floor // HEX 7
    output seg_a,
    output seg_b,
    output seg_c,
    output seg_d,
    output seg_e,
    output seg_f,
    output seg_g
    );
    localparam  WAIT  = 2'b00, 
                UP    = 2'b11,
                DOWN  = 2'b10,
                OPEN  = 2'b01;
    

    // Variable for Loop
    integer i;

    wire clk;               //Clock of module

    reg request_floor[N:1];             //For 5 floors, which floor has request will be assigned to 1 
    integer current_floor;
    integer next_floor;
    reg door;                          //1 = open, 0 = close
    reg [1:0]current_state;
	reg [1:0]next_state ;              //State and next_state of
    reg open_request;             // Open Door when elevator reaches the goal
    reg request_up_from_current;    //Request up from current Floor 
    reg request_down_from_current;  //Request down from current Floor
    reg request_up_from_higher;     //Request up from Higher Floor
    reg request_down_from_higher;   //Request down from higher Floor
    reg request_up_from_lower;      //Request up from lower Floor
    reg request_down_from_lower;    //Request down from lower Floor
    reg [N:1]input_floor_reg;            //Variable for Saving the goal floor        
    reg [N:1]request_down_reg;           //Variable for Saving the goal floor        
    reg [N:1]request_up_reg;            //Variable for Saving the goal floor        
    reg door_count;
    reg up_direction;               //Elevetor is moving up
    reg down_direction;             //Elevetor is moving down
    reg previous_direction;         
    initial 
    begin
        door_led = 0;
        go_up_led = 0;
        go_down_led = 0;
        led_up [N:1] = 5'b00000;
        led_down [N:1] = 5'b00000;
        current_floor = 1;
        next_floor = 1;
        door_count = door_open_time;         
        request_up_from_current = 0;
        request_down_from_current = 0;
        request_up_from_higher = 0;
        request_down_from_higher = 0;
        request_up_from_lower = 0;
        request_down_from_lower = 0;
        input_floor_reg = 5'b00000;
        request_down_reg = 5'b000000;
        request_up_reg = 5'b000000;
        current_state = WAIT;
        next_state = WAIT;
        previous_direction = WAIT;
    end

    //Save the Direction of the Elevator
    always @(posedge clk) begin
    if (current_state == UP || current_state == DOWN) begin
        previous_direction <= current_state;
    end else if (current_state == WAIT && (previous_direction != UP && previous_direction != DOWN)) begin
        if (current_floor == 1) begin
            previous_direction <= UP;
        end else if (current_floor == N) begin
            previous_direction <= DOWN;
        end
    end

    /**Update State after each Clock*/
    end
    always @(posedge clk)
    begin
        current_state <= next_state;
    end

    //Update Floor after Each Clock
    always @(posedge clk)
    begin
        current_floor <= next_floor;
    end

    //Handle
    always @(posedge clk) begin
    for (i = 1; i < N + 1; i = i + 1) begin
        if (input_floor_button[i] == 1)
            input_floor_reg[i] = 1;
        else if (next_floor == i)
            input_floor_reg[i] = 0;

        if (request_up_button[i] == 1)
            request_up_reg[i] = 1;
        else if (next_floor == i)
            request_up_reg[i] = 0;

        if (request_down_button[i] == 1)
            request_down_reg[i] = 1;
        else if (next_floor == i)
            request_down_reg[i] = 0;
    end
end

// Handle Request
always @(*) begin 
    request_up_from_current = 0;
    request_down_from_current = 0;
    request_up_from_higher = 0;
    request_down_from_higher = 0;
    request_up_from_lower = 0;
    request_down_from_lower = 0;

    for (i = 1; i <= N; i = i + 1) begin
        if (request_up_reg[i] || request_down_reg[i] || input_floor_reg[i]) 
            request_floor[i] = 1;
        else 
            request_floor[i] = 0;
    end

    // Handle current floor request
    if (request_floor[next_floor]) begin
        if (input_floor_reg[next_floor] || request_up_reg[next_floor] || request_down_reg[next_floor]) begin
            open_request = 1; // Elevator reaches the requested floor
        end else begin
            open_request = 0;
        end
    end else begin
        open_request = 0;

        // Handle requests from higher floors
        if (current_state == UP || current_state == WAIT) begin
            for (i = 1; i <= N; i = i + 1) begin
                if (i > current_floor && request_floor[i]) begin
                    if (input_floor_reg[i] || request_up_reg[i]) 
                        request_up_from_higher = 1;
                    if (request_down_reg[i]) 
                        request_down_from_higher = 1;
                end
            end
        end

        // Handle requests from lower floors
        if (current_state == DOWN || current_state == WAIT) begin
            for (i = 1; i <= N; i = i + 1) begin
                if (i < current_floor && request_floor[i]) begin
                    if (input_floor_reg[i] || request_down_reg[i]) 
                        request_down_from_lower = 1;
                    if (request_up_reg[i]) 
                        request_up_from_lower = 1;
                end
            end
        end
    end
end


// handle state transitions for the elevator.
always @(*) begin
    if (open_request) begin
        next_state = OPEN;
    end else if (current_state == WAIT) begin
        // If the open button is pressed, transition to the open state
        if (open_button == 1) begin
            next_state = OPEN;
        end else if (close_button == 1) begin
            // If the close button is pressed, remain in the wait state
            next_state = WAIT;
        end else if ((previous_direction == UP && (request_up_from_higher || request_up_from_current || request_down_from_higher)) ||
                    (previous_direction == DOWN && (request_down_from_current || request_down_from_lower || request_up_from_lower))) begin
            // If the previous direction was UP or DOWN and there is a request, maintain the previous direction
            next_state = previous_direction;
        end else if (request_up_from_higher || request_up_from_current || request_down_from_higher) begin
            // If there is a request to go up, transition to the UP state
            next_state = UP;
        end else if (request_down_from_current || request_down_from_lower || request_up_from_lower) begin
            // If there is a request to go down, transition to the DOWN state
            next_state = DOWN;
        end else begin
            // If there are no requests, remain in the wait state
            next_state = WAIT;
        end
    end else if (current_state == OPEN) begin
        // Handle the open state
        if (open_button == 1) begin
            door_count = door_open_time;
            next_state = OPEN;
        end else if (close_button == 1) begin
            door_count = door_open_time;
            next_state = WAIT;
        end else begin
            // Decrement the door count and transition to wait state when time expires
            door_count = door_count - 1;
            if (door_count == 0) begin
                door_count = door_open_time;
                next_state = WAIT;
            end else begin
                next_state = OPEN;
            end
        end
    end else if (current_state == UP) begin
        // Handle the UP state
        if (open_request) begin
            next_state = OPEN;
        end else if (!(request_up_from_current || request_up_from_higher || request_down_from_higher)) begin
            if (request_down_from_lower || request_up_from_lower) 
                next_state = DOWN;
            else 
                next_state = WAIT;
        end else begin
            next_state = UP;
        end
    end else if (current_state == DOWN) begin
        // Handle the DOWN state
        if (open_button || close_button) begin
            next_state = DOWN;
        end else if (!(request_down_from_current || request_down_from_lower || request_up_from_lower)) begin
            if (request_up_from_higher || request_down_from_higher)
                next_state = UP;
            else
                next_state = WAIT;
        end else begin
            next_state = DOWN;
        end
    end
    end




    /** Each State of Elevator**/
    always @(*)
    begin
        case (current_state)
        OPEN:
        begin
            door = 1;
            up_direction = 0;
            down_direction = 0;
            next_floor = current_floor;
        end
        WAIT:
        begin
            door = 0;
            up_direction = 0;
            down_direction = 0;
            next_floor = current_floor;
        end
        UP:
        begin
        door = 0;
        up_direction = 1;
        down_direction = 0;
    
        // Thay đổi logic cập nhật current_floor và next_floor
        if (request_floor[current_floor])
        begin
            next_floor = current_floor;
        end
        else if (current_floor < N)
        begin
        next_floor = current_floor + 1;
        end
        else
        begin
        next_floor = N;
        end

    end
    DOWN:
    begin
    door = 0;
    up_direction = 0;
    down_direction = 1;

    // Thay đổi logic cập nhật current_floor và next_floor
    if (request_floor[current_floor])
        begin
            next_floor = current_floor;
        end 
    else if (current_floor > 1)
    begin
        next_floor = current_floor - 1;
    end
    else
    begin
        next_floor = 1;
    end
    end
        default: //WAIT
        begin
            door = 0;
            up_direction = 0;
            down_direction = 0;
            next_floor = current_floor;
        end
        endcase
    if (door == 1)
    begin
        door_led = 1;
    end
    else door_led = 0;
    end


    always @(*)
    begin //output;
        if (up_direction && !down_direction)
        begin
            go_up_led = 1;
        end
        else if (down_direction && !up_direction)
        begin
            go_down_led = 1;
        end
        else 
        begin
            go_down_led = 0;
            go_up_led = 0;
        end
        led_up = request_up_reg; 
        led_down = request_down_reg; 
        
    end

    clk_gen_module #(board_freq, module_freq) gen_clk (
        .pulse(board_clk),
        .clk(clk));

    // Seven-segment display for current floor
    seven_segment floor_display (
        .input_num({1'b0,current_floor}),
        .a_segment(seg_a),
        .b_segment(seg_b),
        .c_segment(seg_c),
        .d_segment(seg_d),
        .e_segment(seg_e),
        .f_segment(seg_f),
        .g_segment(seg_g));
endmodule