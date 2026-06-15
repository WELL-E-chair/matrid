function draw_box_LTWH(x,c,w)

L = x(1);
T = x(2);
W = x(3);
H = x(4);

line([L L+W L+W L L],[T T T+H T+H T],'Color',c,'LineWidth',w);

end