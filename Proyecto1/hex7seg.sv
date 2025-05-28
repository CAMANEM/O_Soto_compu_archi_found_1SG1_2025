module hex7seg (
    input  logic [3:0] value,
    output logic [6:0] segments
);
    assign segments[6] = (value[1] & value[0] & value[3] & ~value[2]) | 
                         (~value[1] & value[0] & value[3] & value[2]) | 
                         (~value[1] & value[0] & ~value[3] & ~value[2]) | 
                         (~value[1] & ~value[0] & ~value[3] & value[2]);
    
    assign segments[5] = (value[1] & ~value[0] & value[2]) | 
                         (value[1] & value[0] & value[3]) | 
                         (~value[0] & value[3] & value[2]) | 
                         (~value[1] & value[0] & ~value[3] & value[2]);
    
    assign segments[4] = (value[1] & value[3] & value[2]) | 
                            (~value[0] & value[3] & value[2]) | 
                            (value[1] & ~value[0] & ~value[3] & ~value[2]);
    
    assign segments[3] = (value[1] & value[0]& value[2]) | 
                            (value[1] & ~value[0] & value[3] & ~value[2]) | 
                            (~value[1] & value[0] & ~value[3] & ~value[2]) | 
                            (~value[1] & ~value[0] & ~value[3] & value[2]);
    
    assign segments[2] = (value[0] & ~value[3]) | 
                            (~value[1] & value[0] & ~value[2]) | 
                            (~value[1] & ~value[3] & value[2]);
    
    assign segments[1] = (value[1] & ~value[3] & ~value[2]) | 
                            (value[1] & value[0] & ~value[3]) | 
                            (value[0] & ~value[3] & ~value[2]) | 
                            (~value[1] & value[0] & value[3] & value[2]);
    
    assign segments[0] = (~value[1] & ~value[3] & ~value[2]) | 
                            (value[1] & value[0] & ~value[3] & value[2]) | 
                            (~value[1] & ~value[0] & value[3] & value[2]);
endmodule