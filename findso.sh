###
 # @Author: your name
 # @Date: 2020-08-28 12:11:37
 # @LastEditTime: 2020-09-11 03:36:02
 # @LastEditors: Please set LastEditors
 # @Description: In User Settings Edit
 # @FilePath: /AiFrameWork/workspace/findso.sh
###

so_db_dir=all_db_dir
so_dest_dir=dest_dir
so_or_exectuable_path=cpp_test

# 首次正常依赖库文件提取(含软连接)
copy_all_so_2_db(){
    if [ ! -d $so_db_dir ]
    then
        mkdir $so_db_dir
    fi

    so_data=`ldd $so_or_exectuable_path | egrep "\/" | awk '{print $3}'`
    for line in $so_data
    do
        if [ -L $line ]
        then
            # echo ${line//\//,} 所有的/替换为,
            # old_path=${line%$(basename ${line})} #提取原文件的路径，不包含文件名,最后带/; 也可用dirname　文件所在目录

            real_full_name=`readlink -f $line`
            echo $real_full_name
            echo "cp file $real_full_name to $so_db_dir"
            cp $real_full_name $so_db_dir
            echo "cp link $line to $so_db_dir"
            cp -d $line $so_db_dir

            # link_file_name=$so_db_dir/${line##*/} 方法一
            link_file_name=$so_db_dir/$(basename $line) #方法二
            real_file_name=$(basename $real_full_name)
            rm $link_file_name
            ln -s $real_file_name $link_file_name #重新建立软链接
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
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$so_dest_dir

    while :
    do
        so_data=`ldd $so_or_exectuable_path | egrep 'not found' |  awk  '{print  $1}'`
        num=0
        for line in $so_data
        do
            num=1
            src_file=$so_db_dir/$line
            if [ -L $src_file ]
            then
                real_full_name=`readlink -f $src_file`

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
