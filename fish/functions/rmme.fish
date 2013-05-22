function rmme
	set level 1
    if test (count $argv) -ge 1; and test -n {$argv[1]}
        set level $argv[1]
    end
    for i in (seq (echo $level))
        set dir (basename $PWD)
        cd ..
    end
    echo "About to delete $dir"
    sleep 1
    command rm -rf $dir
end
