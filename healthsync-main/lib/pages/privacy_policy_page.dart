import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.privacy_tip,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Last updated: August 6, 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Introduction',
              'HealthSync ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),

            _buildSection(
              'Information We Collect',
              'We may collect information about you in a variety of ways. The information we may collect via the App includes:\n\n'
                  '• Personal Data: Personally identifiable information, such as your name, email address, and demographic information that you voluntarily give to us when you register or use certain features of the App.\n\n'
                  '• Health Information: Medical prescriptions, test reports, medication schedules, and health-related data that you input into the App.\n\n'
                  '• Device Data: Information about your mobile device, including device ID, operating system, and mobile network information.\n\n'
                  '• Usage Data: Information about how you access and use the App, including your preferences and settings.',
            ),

            _buildSection(
              'Use of Your Information',
              'Having accurate information about you permits us to provide you with a smooth, efficient, and customized experience. Specifically, we may use information collected about you via the App to:\n\n'
                  '• Create and manage your account\n'
                  '• Process your transactions and send you related information\n'
                  '• Send you administrative information, such as changes to our terms, conditions, and policies\n'
                  '• Provide you with targeted advertising and promotional materials\n'
                  '• Request feedback and contact you about your use of the App\n'
                  '• Resolve disputes and troubleshoot problems\n'
                  '• Respond to product and customer service requests\n'
                  '• Protect against fraudulent transactions and other illegal activities',
            ),

            _buildSection(
              'Health Information Security',
              'Your health information is extremely sensitive, and we take special care to protect it:\n\n'
                  '• All health data is encrypted both in transit and at rest\n'
                  '• We use industry-standard security protocols to protect your information\n'
                  '• Access to your health data is restricted to authorized personnel only\n'
                  '• We regularly audit our security practices and update them as needed\n'
                  '• Your health data is stored locally on your device and optionally backed up securely',
            ),

            _buildSection(
              'Disclosure of Your Information',
              'We may share information we have collected about you in certain situations. Your information may be disclosed as follows:\n\n'
                  '• By Law or to Protect Rights: If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others.\n\n'
                  '• Business Transfers: We may share or transfer your information in connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.\n\n'
                  '• With Your Consent: We may disclose your personal information for any other purpose with your consent.',
            ),

            _buildSection(
              'Data Retention',
              'We will retain your information only as long as necessary to fulfill the purposes for which it was collected, including for the purposes of satisfying any legal, accounting, or reporting requirements. When we no longer need your personal information, we will securely delete or anonymize it.',
            ),

            _buildSection(
              'Your Privacy Rights',
              'Depending on your location, you may have the following rights regarding your personal information:\n\n'
                  '• Access: You may request access to your personal information\n'
                  '• Correction: You may request that we correct any inaccurate or incomplete personal information\n'
                  '• Deletion: You may request that we delete your personal information\n'
                  '• Portability: You may request a copy of your personal information in a structured, machine-readable format\n'
                  '• Objection: You may object to our processing of your personal information\n'
                  '• Restriction: You may request that we restrict our processing of your personal information',
            ),

            _buildSection(
              'Children\'s Privacy',
              'We do not knowingly collect information from children under the age of 13. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us. If we become aware that we have collected personal information from children without verification of parental consent, we take steps to remove that information from our servers.',
            ),

            _buildSection(
              'International Data Transfers',
              'Your information, including personal data, may be transferred to — and maintained on — computers located outside of your state, province, country, or other governmental jurisdiction where the data protection laws may differ from those of your jurisdiction.',
            ),

            _buildSection(
              'Changes to This Privacy Policy',
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "last updated" date. You are advised to review this Privacy Policy periodically for any changes.',
            ),

            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us:\n\n'
                  'Email: privacy@healthsync.com\n'
                  'Address: [Your Company Address]\n'
                  'Phone: [Your Phone Number]',
            ),

            const SizedBox(height: 32),

            // Agreement Checkbox (for new users)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agreement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'By using HealthSync, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Thank you for reviewing our Privacy Policy'),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('I Understand'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
