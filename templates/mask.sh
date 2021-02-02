#Deletes shortest match of $substring '/*Complet*' from back of $x
RUNPATH=$(echo ${RUN_TO_DEMUX_DIR%/*Complet*})		# ../PATH/TO/sequencers/johnsawyers/201113_JOHNSAWYERS_0252_000000000-G6H72
IFS='/'
array=($RUNPATH)					# ( PATH TO sequencers johnsawyers 201113_JOHNSAWYERS_0252_000000000-G6H72 )
MACHINE="${array[-2]}"					# johnsawyers
RUN_TO_DEMUX="${array[-1]}" 				# 201113_JOHNSAWYERS_0252_000000000-G6H72
IFS=','

# TODO - uncomment
# echo $RUN_TO_DEMUX | mail -s "IGO Cluster New Run Sent for Demuxing" mcmanamd@mskcc.org naborsd@mskcc.org streidd@mskcc.org

RUN_INFO_PATH=${RUNPATH}/RunInfo.xml

HI_SEQ="jax momo pitt kim"
NOVA_SEQ="diana michelle"
MI_SEQ="vic johnsawyers toms ayaan"
NEXT_SEQ="scott"

IsR2Index=$(cat $RUN_INFO_PATH | grep "Read Number=\"2\"" | awk '{IsIt=match($0,"=\"N\""); if (IsIt>0) print "NOTINDEX"; else print "ISINDEX" }')
R1=$( cat $RUN_INFO_PATH | grep "Number=\"1\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
R2=$( cat $RUN_INFO_PATH | grep "Number=\"2\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
R3=$( cat $RUN_INFO_PATH | grep "Number=\"3\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')
R4=$( cat $RUN_INFO_PATH | grep "Number=\"4\"" | awk '{posCycle=match($0,"s=");print substr($0,posCycle+3,5)}' | awk '{PosIndex=match($0,"\""); print substr($0,1,PosIndex-1)}')

ADD_N=""      # NovaSeqs & MiSeqs do NOT add an "n" in their mask
if [[ "${HI_SEQ} ${NEXT_SEQ}" == *"${MACHINE}"* ]]; then
  ADD_N="n"   # NextSeqs & HiSeqs add an "n" in their mask
fi

#DEALING WITH "NO INDEX" PE CASES
if [ "$R3" != '' ] ; then
  MASK="Y${R1}${ADD_N},I${R2},Y${R3}${ADD_N}"
else
  if [ "$IsR2IndexMiSeq" == "ISINDEX" ]; then
    MASK="Y${R1}${ADD_N},I${R2}${ADD_N}"
  else
    MASK="Y${R1}${ADD_N},Y${R2}${ADD_N}"
  fi
fi

if [ "$R2" == '' ] ; then
  MASK="Y${R1}${ADD_N}"
fi

if [ "$R4" != '' ]; then
  MASK="Y${R1}${ADD_N},I${R2}${ADD_N},I${R3}${ADD_N},Y${R4}${ADD_N}"
fi

