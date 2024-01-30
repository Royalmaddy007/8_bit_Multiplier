module multiplier(
                input clock,
                input reset,
                input switch,
                input [7:0] number,
                output reg[6:0] segment,
                output reg[3:0] segment_select,
                output reg[15:0] product
                    );
    reg [7:0] num1;
    reg [7:0] num2;
    // reg [15:0] product;
    reg [7:0] counter_multiplication;
    reg values_done;
    reg multi_done;
  	reg [3:0] current_digit;           
  	reg [3:0] digit;
    //parameter D = 4'b0001;D2 = 4'b0010, D3 = 4'b0100, D4 = 4'b1000;
    
    always @(posedge clock)
      begin
        if (reset)
          begin
            num1 <= 0;
            num2 <= 0;
            values_done = 1'b0;
          end
        if ((switch && ~values_done))
          begin
            num1 <= number;
          end
        if ((~switch && ~values_done))
          begin
            num2 <= number;
            values_done = 1'b1;
          end
      end

  always @(clock)
      begin
        if(~values_done)
          begin
            product <= 0;
            counter_multiplication <= 0;
            multi_done <= 1'b0;
          end
        if (values_done)
          begin
            if (counter_multiplication < num2)
              begin
                product <= product + num1;
                counter_multiplication <= counter_multiplication + 1;
              end
            else
              begin
                multi_done <= 1'b1;
              end
          end
      end

  always @(posedge clock)
       begin
         if(multi_done)
           begin
             case (current_digit)
               4'b0001 : begin
                 digit <= product[7:4];
                 current_digit <= 4'b0010;
               end
               4'b0010 : begin
                 digit <= product[11:8];
                 current_digit <= 4'b0100;
               end
               4'b0100 : begin
                 digit <= product[15:12];
                 current_digit <= 4'b1000;
               end
               4'b1000 : begin
                 digit <= product[3:0];
                 current_digit <= 4'b0001;
               end
               default : begin
                 digit <= product[3:0];
                 current_digit <= 4'b0001;
               end
             endcase
			segment_select <= current_digit;
             case (digit)
               4'b0000 : segment <= ~7'b0000001;
               4'b0001 : segment <= ~7'b1001111;
               4'b0010 : segment <= ~7'b0010010;
               4'b0011 : segment <= ~7'b0000110;
               4'b0100 : segment <= ~7'b1001100;
               4'b0101 : segment <= ~7'b0100100;
               4'b0110 : segment <= ~7'b0100000;
               4'b0111 : segment <= ~7'b0001111;
               4'b1000 : segment <= ~7'b0000000;
               4'b1001 : segment <= ~7'b0000100;
               4'b1010 : segment <= 7'b0011101;
               4'b1011 : segment <= 7'b0011111;
               4'b1100 : segment <= 7'b1001110;
               4'b1101 : segment <= 7'b0111101;
               4'b1110 : segment <= 7'b1101111;
               4'b1111 : segment <= 7'b1000111;
               default : segment <= ~7'b1111111;
             endcase
           end
       end
endmodule





module multiplier_tb();
    wire[6:0] segment;
    wire[3:0] segment_select;
    reg clock;
    reg reset;
    reg switch;
    reg[7:0] number;
    reg [7:0] number1,number2;
    wire[15:0] product;
    
    multiplier DUT(
                .clock(clock),
                .reset(reset),
                .switch(switch),
                .number(number),
                .segment(segment),
                .segment_select(segment_select),
                .product(product));
    
    initial
      begin
        clock = 1'b0;
        repeat (100000)
          #1 clock = ~clock;
      end
    
    initial
        begin
        reset = 1;
        #5 reset = 0;
        #5 switch = 1;
        number = 8'd7;
        number1 = number;
        #5 switch = 0;
        number = 8'd8;
		number2 = number;
        repeat (100) @(posedge clock);
        $finish;
        end

    initial 
        begin
          $monitor($time, " Switch=%b number=%d product=%h segment_sel=%b segment=%b", switch, number,product, segment_select, segment);
            $dumpfile("Project_simulation.vcd");
            $dumpvars(0,multiplier_tb);
        end
    
endmodule