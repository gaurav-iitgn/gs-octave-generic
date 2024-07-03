1;
pkg load io;

function [updated_celldata] = crunch_data(data, celldata, name, rid, cid, wt=1)
  colname = cellstr([name, " Weighted Total"]);
 
  data(find(isnan(data))) = 0; %set NaN to zero
  
  if (cid.start != cid.end)
    colname = [cellstr([name, " Total"]), colname];
    colTotal = sum(data(rid.start:rid.end, cid.start:cid.end), 2);
  else
    colTotal = data(rid.start:rid.end, cid.start:cid.end);
  endif
  colIdealMax = colTotal(end);
  colWtTotal = colTotal * wt * 100 / colIdealMax;
  
  newcol = colname;
  if (cid.start != cid.end)
    newcol = [colname; num2cell([colTotal, colWtTotal])];
  else
    newcol = [colname; num2cell(colWtTotal)];
  endif
  nrow_original = size(celldata, 1);
  nrow_new = size(newcol, 1);
  arow = nrow_original - nrow_new
  
  % statistics rows in the following order:
  %   stddev; max; avg; min
  newcolnum = cell2mat(newcol(rid.start:rid.end-1, :));
  stats_rows = [std(newcolnum); max(newcolnum); mean(newcolnum); min(newcolnum)];
  
  updated_celldata = [celldata, [newcol; num2cell(stats_rows)]];
endfunction

function process-marks()
  printf("Dummy function\n");
endfunction


infile = "ce304-marks-2024-04-27.xlsx";
outfile = "outfile.xlsx";

[ndata, ~, rdata] = xlsread(infile, "All-Marks");
[nrow, ncol] = size(rdata);

% useful sub-cell arrays & indexes
headers = rdata(1,:);

rid.start = 2; %data starts after the header row index start
names = rdata(2:end, 2);

%data ends just before the "Ideal Full Marks" row index end
%include the Idea Full Marks row also in all calculations
rid.end = find(ismember(rdata(:,2), "Ideal Full Marks"));

% for relevant data columns
assgn.start = 6;
assgn.end = 12;
class.start = 14;
class.end = 17;
tut.start = 19;
tut.end = 28;
exam1.start = exam1.end = 31;
exam2.start = exam2.end = 32;

rollnos = cell2mat(rdata(rid.start:rid.end-1, 1));
% index of "A1"
A1_idx = find(ismember(headers, "A1"));

rdata = crunch_data(ndata, rdata, "Assignment", rid, assgn, 0.2);
rdata = crunch_data(ndata, rdata, "Exam 1", rid, exam1, 0.15);
rdata = crunch_data(ndata, rdata, "Class", rid, class, 0.15);

xlswrite(outfile, rdata);