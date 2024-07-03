## Copyright (C) 2024 Gaurav Srivastava
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Author: Gaurav Srivastava <gaurav@gaurav-hpenvy>
## Created: 2024-07-02

function retval = toggle_comma_sep (num)
  %% Toggles comma separation in numbers in Indian style.
  %% e.g.: If a number 434323.45 is given as input, returns "4,34,323.45"
  %%       If a string "4,34,323.45" is given as input, returns 434323.45
  
  % if input is a string with commas, remove commas and return as a number
  if (ischar(num))
    retval = str2num(strrep(num, ",", ""));
    return
  endif
  
  % split part before and after decimal
  num_split_str = strsplit(num2str(num), ".");
  num_main = num_split_str{1};
  if ( length(num_split_str) == 2 )
    num_dec  = num_split_str{2};  
  endif
  
  % work on the main part
  if ( num < 1000 )
    retval = num2str(num);
    return
  endif
  
  % when number is greater than (1,000), first comma appears three places from 
  % the right
  retval = [num_main(1:end-3), "," num_main(end-2:end)];
  
  % when the number is greater than (1,00,000), insert a comma after every
  % second position
  if ( num > 100000 )
    retval_cell = {};
    remaining_str = strsplit(retval, ","){1};
    final_right_str = strsplit(retval, ","){2};
    if (mod(length(remaining_str), 2) == 0)
      % even length string
      retval_cell = even_string_comma(remaining_str);
    else
      % odd length string 
      retval_cell{end+1} = remaining_str(1);
      retval_cell = [retval_cell, even_string_comma(remaining_str(2:end))];
    endif
    retval_cell{end+1} = final_right_str;
    retval = strjoin(retval_cell, ",");
  endif
  
  % add back the decimal part, if any
  if (length(num_split_str) == 2)
    retval = [retval, ".", num_dec];
  endif
endfunction

function out_cell = even_string_comma(instring)
  if (mod(length(instring), 2) != 0 )
    error("Expecting a string of whose length is even.");
  endif
  out_cell = {};
  for (i = 1:2:length(instring))
    out_cell{end+1} = substr(instring, i, 2);
  endfor
endfunction

