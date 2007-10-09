#!/usr/bin/perl
###############

$topdir = shift;
$levels = shift;
$hidden = shift;
$prevline = shift;

$levels = 2 if !defined ($levels);

$hiddenopt = $hidden ? '-a' : '';

$topdir =~ s/\/?$/\//;

chdir $topdir;

open (TREE, "tree -F $hiddenopt -L $levels 2>/dev/null |") or die;
#open (TREE, "tree -F -l -L $levels |") or die;

my @lines = <TREE>;

$numlines = @lines;

# nothing in current dir
if ($numlines <= 3)
{
	print defined ($prevline) ? $prevline : $topdir, "\n";
	exit;
}

# parse line passed in
if (defined ($prevline))
{
	$prevline =~ m/^([-| `]+)(.*?)([{} ]*)$/;

	$pre = $1;
	$mid = $2;
	$pst = $3;

	print $pre, $mid, " {{{\n";

	$pre =~ s/`-- /    /g;
	$pre =~ s/\|-- /\|   /g;
}
else
{
	print $topdir, " {{{\n";
}

$foldlevel = 1;

# skip first line, last 3
for ($i = 1; $i < $numlines - 3; $i++)
{
	$line = $lines[$i];

	# dir
	if ($line =~ /\/$/)
	{
		$line =~ m/^([-| `]+)/;
		$folds = length ($1) / 4;

		# check next line
		$nextline = $lines[$i+1];
		$nextline =~ m/^([-| `]+)/;
		$nextfolds = length ($1) / 4;

		if ($nextfolds > $folds)
		{
			$line =~ s/$/ {{{/;
			$foldlevel++;
			print $pre, $line;
			next;
		}
	}

	# last leaf on branch
	if ($line =~ /`--/)
	{
		$line =~ m/^([-| `]+)/;
		$foldtext = $1;
		$folds = length ($foldtext) / 4;
		$bars = 0;
		while ($foldtext =~ /\|/g) { $bars++; }

		$foldlevel = $foldlevel - ($folds - $bars);
		$closes = ' }}}' x ($folds - $bars);
		$line =~ s/$/$closes/;
	}

	print $pre, $line;
}

# handle last real line
$line = $lines[$numlines - 3];
chop $line;
print $pre, $line, $pst, ' }}}' x $foldlevel, "\n";

