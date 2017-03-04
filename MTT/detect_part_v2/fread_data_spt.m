% function out = fread_data_spt(filename, param)
%
% EN/ extracts from the input file, the info concerning
% a given parameter, for all trajectories
%
% Format of the output file:
% lines (modulo 8) correspond to time/image number
% columns correspond to particles,
% the number of particles increasing with time,
% at the beginning of each line, we indicate
% the current number of particles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FR/ extrait du fichier d'entree, les infos concernant
% un parametre donne, pour toutes les trajectoires
%
% Format du fichier de sortie :
% les lignes (modulo 8) correspondent au temps/numero d_image
% les colonnes correspondent aux particules,
% le nombre de particules augmentant au cours du temps,
% en debut de chaque ligne on renvoie le nombre de
% particules en cours


function tab_out = fread_data_spt(filename, param)

%%% Estimation/Reconnexion
%%%              1    2  3     4       5          6          7      8
%%% tab_param = [num, t, i,    j,      alpha,     rayon,     m0,   ,blink] 
%%% tab_var =   [num, t, sig_i,sig_jj, sig_alpha, sig_rayon, sig_b ,blink] 

  fid = fopen(filename, 'rt','native') ;
  value =  fscanf(fid, '%d', 2) ;
  nb_part_max = value(1) ;
  nb_t = value(2) ;

  tab_out = zeros(nb_part_max, nb_t) ;

  %% on se cale sur le debut des donnees
  ligne = fgets(fid) ;
  while (strcmp(ligne(1:14), '# NEW_DATA_SPT') == 0)
    ligne = fgets(fid) ;
  end%while

  for t=1:nb_t
    for p=2:8
      value =  fscanf(fid, '%d:', 2) ;
      nb_part = value(1) ;
      param_lu = value(2) ;
      
      ligne = fgets(fid) ;

      if (param_lu == param)
	[values, cnt] =  sscanf(ligne(2:end), '%f', nb_part) ; %#ok
 	tab_out(1:nb_part, t) = values(:);
      end%if
    end%for
  %% saut de ligne  # NEW_DATA_SPT
  [ligne, cnt] = fgets(fid) ; %#ok

  end%for
  fclose(fid) ;

end %function
