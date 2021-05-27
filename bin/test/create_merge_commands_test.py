import unittest
import sys

sys.path.append('.')        # If running from bin/test
sys.path.append('..')       # If running from bin
from create_merge_commands import get_merge_commands, main
import config

PROD_BAM = 'P09455_S___06302_AG_125___C-4RKTFD___Tumor.bam'        # TODO - now there isn't an example of same
TANGO_BAM = 'P09455_S___06302_AG_125___C-4RKTFD___Tumor.bam'

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
            '/ifs/res/GCL/hiseq/Stats/JAX_0375_AHFGVNBBXY/JAX_0375_AHFGVNBBXY___P09455_S___S19-48533_IGO_09455_S_1___GRCh37.bam',
            '/ifs/res/GCL/hiseq/Stats/JAX_0375_AHFGVNBBXY/JAX_0375_AHFGVNBBXY___P09455_S___C-19-208557_IGO_09455_S_5___GRCh37.bam',
            '/ifs/res/GCL/hiseq/Stats/JAX_0375_AHFGVNBBXY/JAX_0375_AHFGVNBBXY___P09455_S___S19-53420_IGO_09455_S_2___GRCh37.bam']
        project = 'P09455_S'
        content = get_merge_commands(files, project, config.LIMS_HOST_PROD)
        expected_content = "ln -s /ifs/res/GCL/hiseq/Stats/JAX_0375_AHFGVNBBXY/JAX_0375_AHFGVNBBXY___P09455_S___S19-48533_IGO_09455_S_1___GRCh37.bam P09455_S___09455_S_1___C-7JJ452___Tumor.bam\n" + \
                           "ln -s /ifs/res/GCL/hiseq/Stats/JAX_0375_AHFGVNBBXY/JAX_0375_AHFGVNBBXY___P09455_S___C-19-208557_IGO_09455_S_5___GRCh37.bam P09455_S___09455_S_5___C-J0UH5P___Tumor.bam\n" + \
                           "ln -s /ifs/res/GCL/hiseq/Stats/JAX_0375_AHFGVNBBXY/JAX_0375_AHFGVNBBXY___P09455_S___S19-53420_IGO_09455_S_2___GRCh37.bam P09455_S___09455_S_2___C-2M22RC___Tumor.bam\n"
        self.assertEqual(content, expected_content)

    def test_corrected_ids(self):
        project = 'PROJECT'
        test_cases = []
        '''
        test_cases = [
        ]
        '''

        for case in test_cases:
            cmd = get_merge_commands([case[0]], project, config.LIMS_HOST_PROD)
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
            cmd = get_merge_commands([case[0]], project, config.LIMS_HOST_PROD)
            bam = cmd.split(" ")[-1]
            self.assertEqual(bam.strip(), case[1])


    def test_command_line_args_tango(self):
        """ Runs ./create_merge_commands.py WITH the tango option enabled (-t)
        """
        print("Running TANGO")

        # Model command line arguments
        output = 'TEST_OUTPUT.txt'
        project = 'P09455_S'
        file = '/ifs/res/GCL/hiseq/Stats/DIANA_0173_AH73G5DSXY_RENAME/DIANA_0173_AH73G5DSXY_RENAME___P06302_AG___MSK-MB-0045-CF1-MSK10461a-p_IGO_06302_AG_125___GRCh37.bam'
        args = ['./create_merge_commands.py']
        args.append(output)
        args.append(project)
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
        project = 'P09455_S'
        file = '/ifs/res/GCL/hiseq/Stats/DIANA_0173_AH73G5DSXY_RENAME/DIANA_0173_AH73G5DSXY_RENAME___P06302_AG___MSK-MB-0045-CF1-MSK10461a-p_IGO_06302_AG_125___GRCh37.bam'
        args = ['./create_merge_commands.py']
        args.append(output)
        args.append(project)
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
        content = get_merge_commands(files, project, config.LIMS_HOST_PROD)
        expected_content = "ln -s %s 10862___10862_3___HSS12___Normal.bam\n" % original_bam
        self.assertEqual(content, expected_content)

    def test_overridden_manifests(self):
        TEST_PROJECT = "TEST-PROJECT"
        for overridden_sample in ["05841_N_1007", "06457_E_10013", "09641_Z_10040", "09641_Z_10056", "09641_Z_10083"]:
            original_bam = '/ifs/res/GCL/hiseq/Stats/TEST-RUN/TEST-RUN___{}___HSS12_IGO_{}___GRCh37.bam'.format(TEST_PROJECT, overridden_sample)
            files = [ original_bam ]
            content = get_merge_commands(files, TEST_PROJECT, config.LIMS_HOST_PROD)
            expected_content = "ln -s %s %s___%s___%s___Tumor.bam\n" % (original_bam, TEST_PROJECT, overridden_sample, overridden_sample)
            self.assertEqual(content, expected_content)

if __name__ == '__main__':
    unittest.main()
