function shade_area(t, y1, y2, sig, color, alpha)

y2_sig             = y2;
y2_sig(isnan(sig)) = y1(isnan(sig));

y1_sig             = y1;
y1_sig(isnan(sig)) = y2(isnan(sig));

x2                 = [t, fliplr(t)];
inBetween          = [y2_sig, fliplr(y1)];
fill(x2, inBetween, color, 'edgecolor', 'none', 'FaceAlpha', alpha);

x2                 = [t, fliplr(t)];
inBetween          = [y2, fliplr(y1_sig)];
fill(x2, inBetween, color, 'edgecolor', 'none', 'FaceAlpha', alpha);
