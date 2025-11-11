function point = ms_to_point(ms,type)
if type ==1
   point = ms/(1000/250)+50;
end

if type == 2
    point = (ms-50)*4;
end 

end