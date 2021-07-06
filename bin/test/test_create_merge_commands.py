import unittest
import sys

sys.path.append('.')        # If running from bin/test
sys.path.append('..')       # If running from bin
from create_merge_commands import get_merge_commands, main
import config

PROD_BAM = './P06302_AG/06302_AG_125___NO_CMO_PID___NA.bam'        # TODO - now there isn't an example of same
TANGO_BAM = './P06302_AG/06302_AG_125___NO_CMO_PID___NA.bam'

class CreateMergeCommand(unittest.TestCase):
    """
    $ python3 create_merge_commands_test.py CreateMergeCommand.test_command_line_args
    $ python3 create_merge_commands_test.py CreateMergeCommand.test_merge_commands
    $ python3 create_merge_commands_test.py CreateMergeCommand.test_corrected_ids
    $ python3 create_merge_commands_test.py CreateMergeCommand.test_uncorrected_ids
    $ python3 create_merge_commands_test.py CreateMergeCommand.test_command_line_args
    $ python3 create_merge_commands_test.py CreateMergeCommand.test_command_line_args_tango
    $ python3 create_merge_commands_test.py CreateMergeCommand.test_missing_cmoPatientId_sampleName_replacement
    """
    def test_merge_commands(self):
        """
        Test that it can sum a list of integers
        """
        files = [
            'JAX_0375_AHFGVNBBXY___P09455_S___S19-48533_IGO_09455_S_1___GRCh37.bam',
            'JAX_0375_AHFGVNBBXY___P09455_S___C-19-208557_IGO_09455_S_5___GRCh37.bam',
            'JAX_0375_AHFGVNBBXY___P09455_S___S19-53420_IGO_09455_S_2___GRCh37.bam']
        bam_dir = '/igo/staging/BAM'
        content = get_merge_commands(files, bam_dir, config.LIMS_HOST_PROD, "/usr/bin/samtools")
        expected_content = "mkdir -p $(dirname /igo/staging/BAM/P09455_S/09455_S_1___NO_CMO_PID___NA.bam) && cp JAX_0375_AHFGVNBBXY___P09455_S___S19-48533_IGO_09455_S_1___GRCh37.bam /igo/staging/BAM/P09455_S/09455_S_1___NO_CMO_PID___NA.bam\n" + \
                           "mkdir -p $(dirname /igo/staging/BAM/P09455_S/09455_S_5___NO_CMO_PID___NA.bam) && cp JAX_0375_AHFGVNBBXY___P09455_S___C-19-208557_IGO_09455_S_5___GRCh37.bam /igo/staging/BAM/P09455_S/09455_S_5___NO_CMO_PID___NA.bam\n" + \
                           "mkdir -p $(dirname /igo/staging/BAM/P09455_S/09455_S_2___NO_CMO_PID___NA.bam) && cp JAX_0375_AHFGVNBBXY___P09455_S___S19-53420_IGO_09455_S_2___GRCh37.bam /igo/staging/BAM/P09455_S/09455_S_2___NO_CMO_PID___NA.bam\n"
        self.assertEqual(content, expected_content)

    def test_corrected_ids(self):
        project = 'PROJECT'
        test_cases = []
        '''
        test_cases = [
        ]
        '''

        for case in test_cases:
            cmd = get_merge_commands([case[0]], project, config.LIMS_HOST_PROD, "/usr/bin/samtools")
            bam = cmd.split(" ")[-1]
            self.assertEqual(bam.strip(), case[1])

    def test_uncorrected_ids(self):
        project = 'PROJECT'
        test_cases = []
        '''
        test_cases = [
        ]
        '''

        for case in test_cases:
            cmd = get_merge_commands([case[0]], project, config.LIMS_HOST_PROD, "/usr/bin/samtools")
            bam = cmd.split(" ")[-1]
            self.assertEqual(bam.strip(), case[1])


    def test_command_line_args_tango(self):
        """ Runs ./create_merge_commands.py WITH the tango option enabled (-t)
        """
        print("Running TANGO")

        # Model command line arguments
        output = 'TEST_OUTPUT.txt'
        dir_to_write_bams = '.'
        file = '/ifs/res/GCL/hiseq/Stats/DIANA_0173_AH73G5DSXY_RENAME/DIANA_0173_AH73G5DSXY_RENAME___P06302_AG___MSK-MB-0045-CF1-MSK10461a-p_IGO_06302_AG_125___GRCh37.bam'
        args = ['./create_merge_commands.py']
        args.append(output)
        args.append(dir_to_write_bams)
        args.append('-t')
        args.append(file)
        sys.argv = args

        # Should write to output file
        main()

        f = open(output, "r")
        command = f.read().strip()
        bam_name = command.split(' ')[-1]

        self.assertEqual(bam_name, TANGO_BAM)

    def test_command_line_args(self):
        """ Runs ./create_merge_commands.py WITHOUT the tango option enabled
            Writes to an output file
        """
        print("Running PROD")

        # Model command line arguments
        output = 'TEST_OUTPUT.txt'
        dir_to_write_bams = '.'
        file = '/ifs/res/GCL/hiseq/Stats/DIANA_0173_AH73G5DSXY_RENAME/DIANA_0173_AH73G5DSXY_RENAME___P06302_AG___MSK-MB-0045-CF1-MSK10461a-p_IGO_06302_AG_125___GRCh37.bam'
        args = ['./create_merge_commands.py']
        args.append(output)
        args.append(dir_to_write_bams)
        args.append(file)
        sys.argv = args

        # Should write to output file
        main()

        f = open(output, "r")
        command = f.read().strip()
        bam_name = command.split(' ')[-1]

        self.assertEqual(bam_name, PROD_BAM)

    def test_missing_cmoPatientId_sampleName_replacement(self):
        """
        https://igolims.mskcc.org:8443/LimsRest/api/getSampleManifest?igoSampleId=10862_4&igoSampleId=10862_3&igoSampleId=10862_5&igoSampleId=10862_2
        [
            {
                "igoId": "TEST_ID",
                "cmoSampleName": "",
                "sampleName": "REPLACEMENT",        // <- Should choose this
                "cmoSampleClass": "",
                "cmoPatientId": "",                 // <- If this is missing
                "investigatorSampleId": "",
                "oncoTreeCode": null,
                ...
            }
            ...
        ]
        """
        original_bam = '/ifs/res/GCL/hiseq/Stats/JAX_0435_AHH3F7BBXY/JAX_0435_AHH3F7BBXY___P10862___HSS12_IGO_10862_3___GRCh37.bam'
        files = [ original_bam ]
        project = '10862'
        content = get_merge_commands(files, project, config.LIMS_HOST_PROD, "/usr/bin/samtools")
        expected_content = "mkdir -p $(dirname 10862/P10862/10862_3___NO_CMO_PID___NA.bam) && cp %s 10862/P10862/10862_3___NO_CMO_PID___NA.bam\n" % original_bam
        self.assertEqual(content, expected_content)

if __name__ == '__main__':
    unittest.main()
