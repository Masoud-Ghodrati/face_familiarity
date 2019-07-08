clear all
close all
clc

param.analysis_figures_dir = cd;
pdf_file_name              = 'rdm';

scale = 1.2;
shift = 1;
a = [1 1 1 0 0 0;
    1 1 1 0 0 0;
    1 1 1 0 0 0;
    0 0 0 1 1 1;
    0 0 0 1 1 1;
    0 0 0 1 1 1];
b = scale * kron(a, ones(10)) + shift;
c = b + randn(size(b));
d = b + 0.7*randn(size(b));

subplot(221)
imagesc(c)
axis off
subplot(222)
imagesc(b)
axis off
subplot(223)
imagesc(d)
axis off

fig                 = gcf;
fig.PaperUnits      = 'centimeters';
fig.Position        = [100 100 200 200];
fig.PaperSize       = [10 10];
set(0, 'DefaultFigureRenderer', 'OpenGL');
print('-painters', '-dpdf', [ param.analysis_figures_dir '\' pdf_file_name '_MODELRDM.pdf'],'-r300')
