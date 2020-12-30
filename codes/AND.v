module AND
(
    data1_i,
    data2_i,
    data_o
);

input   [n-1:0]      data1_i, data2_i;
output  [n-1:0]      data_o;

parameter n = 1;

assign data_o = data1_i & data2_i;

endmodule 