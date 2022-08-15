// Copyright @ 2022 Yuqing Guo

// Round Robin Arbiter
// Rotator - Fixed Prioritizer - Rotator


module round_robin_arbiter_4(
    clk,
    reset_n,
    req,
    grant
);

input clk;
input reset_n;
input [3:0] req;

output [3:0] grant;

wire [3:0] req_r0;
wire [3:0] req_r1;
wire [3:0] gnt;
wire at_least_one_req;

reg [3:0] grant;
reg [1:0] select_update;

// rotator-fpr-rotator -> combinational logic
barrel_shifter_right_4 bs4_0 (.in(req), .yout(req_r0), .select(select_update));
fixed_priority_arbiter #(.WIDTH(4)) fpa0 (.req(req_r0), .grant(req_r1));
barrel_shifter_left_4 bs4_1 (.in(req_r1), .yout(gnt), .select(select_update));

// update logic
/*
always @ (*) begin
    case (1'b1)
        gnt[3]: most_recent_grant = 2'b00;
        gnt[2]: most_recent_grant = 2'b11;
        gnt[1]: most_recent_grant = 2'b10;
        gnt[0]: most_recent_grant = 2'b01;
        default: most_recent_grant = 2'b00;
    endcase
end
*/

always @ (posedge clk or negedge reset_n) begin
    
    if (!reset_n) begin
        select_update <= 2'b00;
        grant <= 4'b0000;
    end
    else begin
        grant <= gnt;
        case (1'b1)
            gnt[3]: select_update <= 2'b00;
            gnt[2]: select_update <= 2'b11;
            gnt[1]: select_update <= 2'b10;
            gnt[0]: select_update <= 2'b01;
            default: select_update <= 2'b00;
        endcase
    end 
end

endmodule

module barrel_shifter_right_4 (
    in,
    yout,
    select
);

input [3:0] in;
input [1:0] select;
output [3:0] yout;
reg [3:0] yout;

always @ (*) begin
    
    case(select)
        2'b00: yout = in;
        2'b01: yout = {in[0], in[3:1]};
        2'b10: yout = {in[1:0], in[3:2]};
        2'b11: yout = {in[2:0], in[3]};
    endcase

end

endmodule

module barrel_shifter_left_4 (
    in,
    yout,
    select
);

input [3:0] in;
input [1:0] select;
output [3:0] yout;
reg [3:0] yout;

always @ (*) begin
    
    case(select)
        2'b00: yout = in;
        2'b01: yout = {in[2:0], in[3]};
        2'b10: yout = {in[1:0], in[3:2]};
        2'b11: yout = {in[0], in[3:1]};
    endcase

end

endmodule

module fixed_priority_arbiter(
    req,
    grant
);
parameter WIDTH = 8;

input [WIDTH-1:0] req;
output [WIDTH-1:0] grant;

assign grant = req & (~req + 1);

endmodule