function LobeMaps = poolingMappings

    diameter = 11;
    % M=SiftMaps(Diameter);
    % PS = Diameter*Diameter;

    % Parameters
    alpha_center = 20; %1/alpha_center = 0.05, 0.02 0.03 *mlt
    % rho=[0 0.3 0.4]; VOC % 0.35 0.85 initially 0 0.3 0.7 r1 r2
    rho = [0 0.45 0.6]; % Caltech
    alpha = 4;  %1/alpha = 5.8 2.8 0.3 %0.25 *mlt
    beta = 0.4;  %1/beta = 2.5 1.1 1.2 0.18*mlt

    extended_diameter = diameter*20;    % 20 times the diameter is enough area to
                                       % build the subspaces

    Map = attentional_subspaces(extended_diameter,rho,alpha_center,alpha,beta);

    M = imresize(Map(:,:,8:end),[diameter diameter],'bilinear');

    % Normalisation

    LinMaps = double(M);

    LinMaps = LinMaps ./ repmat(sum(sum(LinMaps)),[diameter,diameter,1]);

    LobeMaps = LinMaps;
    
end % end poolingMappings