
so_db_dir=all_db_dir
so_dest_dir=dest_dir
copy_2_dest=true
so_or_exectuable_path=frame_test

find_real_file_full_name(){ #输入一个符号链接绝对路径，输出真实文件全路径
    a=$1
    while [ -h $a ]
    do

    b=`ls -ld $a|awk '{print $NF}'`
    c=`ls -ld $a|awk '{print $(NF-2)}'`
    [[ $b =~ ^/ ]] && a=$b  || a=`dirname $c`/$b
    done
    echo $a
}

# 首次正常依赖库文件提取(含软连接)
copy_all_so_2_db(){
    if [ ! -d $so_db_dir ]
    then
        mkdir $so_db_dir
    fi

    so_data=`ldd $so_or_exectuable_path | egrep "\/" | awk '{print $3}'`
    for line in $so_data
    do
        if [ -h $line ]
        then
            # echo ${line//\//,} 所有的/替换为,
            # old_path=${line%$(basename ${line})} #提取原文件的路径，不包含文件名,最后带/

            real_full_name=$(find_real_file_full_name $line)

            echo "cp file $real_full_name to $so_db_dir"
            cp $real_full_name $so_db_dir
            echo "cp link $line to $so_db_dir"
            cp -d $line $so_db_dir
        else
            cp $line $so_db_dir
        fi
    done
}

#二次异常提取(含软连)
# ldd $1 | egrep  '=>'   |  awk  '{print  $1}'|grep  -v  vdso >>/${name_01}/a01.txt
copy_need_2_dest(){
    if [ ! -d $so_dest_dir ]
    then
        mkdir $so_dest_dir
    fi
    export LD_LIBRARY_PATH=$so_dest_dir

    while :
    do
        so_data=`ldd $so_or_exectuable_path | egrep 'not found' |  awk  '{print  $1}'`
        num=0
        for line in $so_data
        do
            let num++
            src_file=$so_db_dir/$line
            if [ -h $src_file ]
            then
                real_full_name=$(find_real_file_full_name $src_file)

                echo "cp file $real_full_name to $so_dest_dir"
                cp $real_full_name $so_dest_dir
                echo "cp link $src_file to $so_dest_dir"
                cp -d $src_file $so_dest_dir
            else
                cp $src_file $so_dest_dir
            fi
        done

        if [ $num -eq 0 ]
        then
            break
        fi
    done
}

main(){
    case $1 in
            copy_all_so_2_db)
            copy_all_so_2_db
            ;;
            copy_need_2_dest)
            copy_need_2_dest
            ;;
            *)
            echo -e "\nUSEAGE: $0 [copy_all_so_2_db|copy_need_2_dest]"
    esac
}

main $1