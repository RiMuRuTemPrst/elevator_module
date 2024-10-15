
module seven_segment ( input [3:0] input_num,
                output reg a_segment,
                output reg b_segment,
                output reg c_segment,
                output reg d_segment,
                output reg e_segment,
                output reg f_segment,
                output reg g_segment);
    always @(input_num)
    begin 
      case (input_num)
        4'b0000: //Display number 0
        begin
          a_segment = 0;  b_segment = 0;  c_segment =0;  d_segment = 0;  e_segment =0;  f_segment = 0;  g_segment = 1;  
        end
        4'b0001: //Display number 1
        begin
          a_segment = 1;  b_segment = 0;  c_segment =0;  d_segment =1;  e_segment = 1;  f_segment = 1;  g_segment = 1;
        end
        4'b0010: //Display number 2
        begin
          a_segment = 0;  b_segment = 0;  c_segment = 1;  d_segment =0;  e_segment =0;  f_segment = 1;  g_segment=0;
        end
        4'b0011: //Display number 3
        begin
           a_segment = 0;
           b_segment = 0;
           c_segment = 0;
           d_segment = 0;
           e_segment = 1;
           f_segment = 1;
           g_segment = 0;
        end
        4'b0100: //Display number 4
        begin
           a_segment = 1;
           b_segment = 0;
           c_segment = 0;
           d_segment = 1;
           e_segment = 1;
           f_segment = 0;
           g_segment = 0;
        end
        4'b0101://Display number 5
        begin
           a_segment = 0;
           b_segment = 1;
           c_segment = 0;
           d_segment = 0;
           e_segment = 1;
           f_segment = 0;
           g_segment = 0;
        end
        4'b0110: //Display number 6
        begin
           a_segment = 0;
           b_segment = 1;
           c_segment = 0;
           d_segment = 0;
           e_segment = 0;
           f_segment = 0;
           g_segment = 0;
        end
        4'b0111: //Display number 7
        begin 
           a_segment = 0;
           b_segment = 0;
           c_segment = 0;
           d_segment = 1;
           e_segment = 1;
           f_segment = 1;
           g_segment = 1;
        end
        4'b1000: //Display number 8
        begin
           b_segment = 0;
           a_segment = 0;
           c_segment = 0;
           d_segment = 0;
           e_segment = 0;
           f_segment = 0;
           g_segment = 0;
        end
        4'b1001: //Display number 9
        begin
           a_segment = 0;
           b_segment = 0;
           c_segment = 0;
           d_segment = 0;
           e_segment = 1;
           f_segment = 0;
           g_segment = 0;
        end
        default: begin
            a_segment = 0;  b_segment = 0;  c_segment =0;  d_segment = 0;  e_segment =0;  f_segment = 0;  g_segment = 1; 
        end
        
      endcase
    end

endmodule
