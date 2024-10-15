module clk_gen_module       #(parameter board_freq = 50000000,
//module clk_gen_module       #(parameter board_freq = 5,
                                    module_freq = 1) //Duty  = 50%
                          // Board_freq is the Frequency of the Board, In this code the
                          // Frequency of Module is 1Hz
                        (input pulse,
                        output reg clk);
    
    reg [27:0] freq_counter;
    initial begin
      freq_counter = 0;
    clk = 0;
    end
    
    always @(posedge pulse)
    begin 
        if (freq_counter == (board_freq >> 1)) //Frequency of module is 1Hz
        begin
            clk <= ~clk;
            freq_counter <= 0;
        end
        else  freq_counter <= freq_counter + 1;
    end

    


endmodule
