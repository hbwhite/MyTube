//
//  AboutViewController.m
//  MyTube
//
//  Created by Harrison White on 5/9/11.
//  Copyright 2011 Harrison Apps, LLC. All rights reserved.
//

#import "AboutViewController.h"

// Needed in order to observe when ads load or fail to load.
#import "MyTubeAppDelegate.h"

@implementation AboutViewController

@synthesize theTableView;
@synthesize isAdObserver;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)adDidLoad {
	theTableView.frame = CGRectMake(0, 0, 320, 317);
}

- (void)adDidFailLoad {
	theTableView.frame = CGRectMake(0, 0, 320, 367);
}

- (void)viewWillAppear:(BOOL)animated {
	if (!isAdObserver) {
		isAdObserver = YES;
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adDidLoad) name:kAdDidLoadNotification object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(adDidFailLoad) name:kAdDidFailLoadNotification object:nil];
		if (![[(MyTubeAppDelegate *)[[UIApplication sharedApplication]delegate]bannerViewContainer]isHidden]) {
			[self adDidLoad];
		}
	}
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 123;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"MyTube";
		case 1:
			return @"Copyright © 2012 Harrison Apps, LLC\nAll rights reserved.";
		case 2:
			return @"-----";
		case 3:
			return @"THE FOLLOWING SETS FORTH ATTRIBUTION NOTICES FOR THIRD PARTY SOFTWARE THAT MAY BE CONTAINED IN PORTIONS OF THE MYTUBE PRODUCT.";
		case 4:
			return @"-----";
		case 5:
			return @"The following software may be included in this product: Facebook iOS SDK. This software contains the following license and notice below:";
		case 6:
			return @"Apache License\nVersion 2.0, January 2004\nhttp://www.apache.org/licenses/";
		case 7:
			return @"TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION";
		case 8:
			return @"1. Definitions.";
		case 9:
			return @"\"License\" shall mean the terms and conditions for use, reproduction, and distribution as defined by Sections 1 through 9 of this document.";
		case 10:
			return @"\"Licensor\" shall mean the copyright owner or entity authorized by the copyright owner that is granting the License.";
		case 11:
			return @"\"Legal Entity\" shall mean the union of the acting entity and all other entities that control, are controlled by, or are under common control with that entity. For the purposes of this definition, \"control\" means (i) the power, direct or indirect, to cause the direction or management of such entity, whether by contract or otherwise, or (ii) ownership of fifty percent (50%) or more of the outstanding shares, or (iii) beneficial ownership of such entity.";
		case 12:
			return @"\"You\" (or \"Your\") shall mean an individual or Legal Entity exercising permissions granted by this License.";
		case 13:
			return @"\"Source\" form shall mean the preferred form for making modifications, including but not limited to software source code, documentation source, and configuration files.";
		case 14:
			return @"\"Object\" form shall mean any form resulting from mechanical transformation or translation of a Source form, including but not limited to compiled object code, generated documentation, and conversions to other media types.";
		case 15:
			return @"\"Work\" shall mean the work of authorship, whether in Source or Object form, made available under the License, as indicated by a copyright notice that is included in or attached to the work (an example is provided in the Appendix below).";
		case 16:
			return @"\"Derivative Works\" shall mean any work, whether in Source or Object form, that is based on (or derived from) the Work and for which the editorial revisions, annotations, elaborations, or other modifications represent, as a whole, an original work of authorship. For the purposes of this License, Derivative Works shall not include works that remain separable from, or merely link (or bind by name) to the interfaces of, the Work and Derivative Works thereof.";
		case 17:
			return @"\"Contribution\" shall mean any work of authorship, including the original version of the Work and any modifications or additions to that Work or Derivative Works thereof, that is intentionally submitted to Licensor for inclusion in the Work by the copyright owner or by an individual or Legal Entity authorized to submit on behalf of the copyright owner. For the purposes of this definition, \"submitted\" means any form of electronic, verbal, or written communication sent to the Licensor or its representatives, including but not limited to communication on electronic mailing lists, source code control systems, and issue tracking systems that are managed by, or on behalf of, the Licensor for the purpose of discussing and improving the Work, but excluding communication that is conspicuously marked or otherwise designated in writing by the copyright owner as \"Not a Contribution.\"";
		case 18:
			return @"\"Contributor\" shall mean Licensor and any individual or Legal Entity on behalf of whom a Contribution has been received by Licensor and subsequently incorporated within the Work.";
		case 19:
			return @"2. Grant of Copyright License. Subject to the terms and conditions of this License, each Contributor hereby grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable copyright license to reproduce, prepare Derivative Works of, publicly display, publicly perform, sublicense, and distribute the Work and such Derivative Works in Source or Object form.";
		case 20:
			return @"3. Grant of Patent License. Subject to the terms and conditions of this License, each Contributor hereby grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable (except as stated in this section) patent license to make, have made, use, offer to sell, sell, import, and otherwise transfer the Work, where such license applies only to those patent claims licensable by such Contributor that are necessarily infringed by their Contribution(s) alone or by combination of their Contribution(s) with the Work to which such Contribution(s) was submitted. If You institute patent litigation against any entity (including a cross-claim or counterclaim in a lawsuit) alleging that the Work or a Contribution incorporated within the Work constitutes direct or contributory patent infringement, then any patent licenses granted to You under this License for that Work shall terminate as of the date such litigation is filed.";
		case 21:
			return @"4. Redistribution. You may reproduce and distribute copies of the Work or Derivative Works thereof in any medium, with or without modifications, and in Source or Object form, provided that You meet the following conditions:";
		case 22:
			return @"(a) You must give any other recipients of the Work or Derivative Works a copy of this License; and";
		case 23:
			return @"(b) You must cause any modified files to carry prominent notices stating that You changed the files; and";
		case 24:
			return @"(c) You must retain, in the Source form of any Derivative Works that You distribute, all copyright, patent, trademark, and attribution notices from the Source form of the Work, excluding those notices that do not pertain to any part of the Derivative Works; and";
		case 25:
			return @"(d) If the Work includes a \"NOTICE\" text file as part of its distribution, then any Derivative Works that You distribute must include a readable copy of the attribution notices contained within such NOTICE file, excluding those notices that do not pertain to any part of the Derivative Works, in at least one of the following places: within a NOTICE text file distributed as part of the Derivative Works; within the Source form or documentation, if provided along with the Derivative Works; or, within a display generated by the Derivative Works, if and wherever such third-party notices normally appear. The contents of the NOTICE file are for informational purposes only and do not modify the License. You may add Your own attribution notices within Derivative Works that You distribute, alongside or as an addendum to the NOTICE text from the Work, provided that such additional attribution notices cannot be construed as modifying the License.";
		case 26:
			return @"You may add Your own copyright statement to Your modifications and may provide additional or different license terms and conditions for use, reproduction, or distribution of Your modifications, or for any such Derivative Works as a whole, provided Your use, reproduction, and distribution of the Work otherwise complies with the conditions stated in this License.";
		case 27:
			return @"5. Submission of Contributions. Unless You explicitly state otherwise, any Contribution intentionally submitted for inclusion in the Work by You to the Licensor shall be under the terms and conditions of this License, without any additional terms or conditions. Notwithstanding the above, nothing herein shall supersede or modify the terms of any separate license agreement you may have executed with Licensor regarding such Contributions.";
		case 28:
			return @"6. Trademarks. This License does not grant permission to use the trade names, trademarks, service marks, or product names of the Licensor, except as required for reasonable and customary use in describing the origin of the Work and reproducing the content of the NOTICE file.";
		case 29:
			return @"7. Disclaimer of Warranty. Unless required by applicable law or agreed to in writing, Licensor provides the Work (and each Contributor provides its Contributions) on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied, including, without limitation, any warranties or conditions of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE. You are solely responsible for determining the appropriateness of using or redistributing the Work and assume any risks associated with Your exercise of permissions under this License.";
		case 30:
			return @"8. Limitation of Liability. In no event and under no legal theory, whether in tort (including negligence), contract, or otherwise, unless required by applicable law (such as deliberate and grossly negligent acts) or agreed to in writing, shall any Contributor be liable to You for damages, including any direct, indirect, special, incidental, or consequential damages of any character arising as a result of this License or out of the use or inability to use the Work (including but not limited to damages for loss of goodwill, work stoppage, computer failure or malfunction, or any and all other commercial damages or losses), even if such Contributor has been advised of the possibility of such damages.";
		case 31:
			return @"9. Accepting Warranty or Additional Liability. While redistributing the Work or Derivative Works thereof, You may choose to offer, and charge a fee for, acceptance of support, warranty, indemnity, or other liability obligations and/or rights consistent with this License. However, in accepting such obligations, You may act only on Your own behalf and on Your sole responsibility, not on behalf of any other Contributor, and only if You agree to indemnify, defend, and hold each Contributor harmless for any liability incurred by, or claims asserted against, such Contributor by reason of your accepting any such warranty or additional liability.";
		case 32:
			return @"END OF TERMS AND CONDITIONS";
		case 33:
			return @"APPENDIX: How to apply the Apache License to your work.";
		case 34:
			return @"To apply the Apache License to your work, attach the following boilerplate notice, with the fields enclosed by brackets \"[]\" replaced with your own identifying information. (Don't include the brackets!)  The text should be enclosed in the appropriate comment syntax for the file format. We also recommend that a file or class name and description of purpose be included on the same \"printed page\" as the copyright notice for easier identification within third-party archives.";
		case 35:
			return @"Copyright [yyyy] [name of copyright owner]";
		case 36:
			return @"Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at";
		case 37:
			return @"http://www.apache.org/licenses/LICENSE-2.0";
		case 38:
			return @"Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\nSee the License for the specific language governing permissions and limitations under the License.";
		case 39:
			return @"-----";
		case 40:
			return @"The following software may be included in this product: SBJSON. This software contains the following license and notice below:";
		case 41:
			return @"Copyright (C) 2007-2009 Stig Brautaset. All rights reserved.";
		case 42:
			return @"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:";
		case 43:
			return @"* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.";
		case 44:
			return @"* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.";
		case 45:
			return @"* Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.";
		case 46:
			return @"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.";
		case 47:
			return @"-----";
		case 48:
			return @"The following software may be included in this product: OAuthConsumer. This software contains the following license and notice below:";
		case 49:
			return @"Apache License\nVersion 2.0, January 2004\nhttp://www.apache.org/licenses/";
		case 50:
			return @"TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION";
		case 51:
			return @"1. Definitions.";
		case 52:
			return @"\"License\" shall mean the terms and conditions for use, reproduction, and distribution as defined by Sections 1 through 9 of this document.";
		case 53:
			return @"\"Licensor\" shall mean the copyright owner or entity authorized by the copyright owner that is granting the License.";
		case 54:
			return @"\"Legal Entity\" shall mean the union of the acting entity and all other entities that control, are controlled by, or are under common control with that entity. For the purposes of this definition, \"control\" means (i) the power, direct or indirect, to cause the direction or management of such entity, whether by contract or otherwise, or (ii) ownership of fifty percent (50%) or more of the outstanding shares, or (iii) beneficial ownership of such entity.";
		case 55:
			return @"\"You\" (or \"Your\") shall mean an individual or Legal Entity exercising permissions granted by this License.";
		case 56:
			return @"\"Source\" form shall mean the preferred form for making modifications, including but not limited to software source code, documentation source, and configuration files.";
		case 57:
			return @"\"Object\" form shall mean any form resulting from mechanical transformation or translation of a Source form, including but not limited to compiled object code, generated documentation, and conversions to other media types.";
		case 58:
			return @"\"Work\" shall mean the work of authorship, whether in Source or Object form, made available under the License, as indicated by a copyright notice that is included in or attached to the work (an example is provided in the Appendix below).";
		case 59:
			return @"\"Derivative Works\" shall mean any work, whether in Source or Object form, that is based on (or derived from) the Work and for which the editorial revisions, annotations, elaborations, or other modifications represent, as a whole, an original work of authorship. For the purposes of this License, Derivative Works shall not include works that remain separable from, or merely link (or bind by name) to the interfaces of, the Work and Derivative Works thereof.";
		case 60:
			return @"\"Contribution\" shall mean any work of authorship, including the original version of the Work and any modifications or additions to that Work or Derivative Works thereof, that is intentionally submitted to Licensor for inclusion in the Work by the copyright owner or by an individual or Legal Entity authorized to submit on behalf of the copyright owner. For the purposes of this definition, \"submitted\" means any form of electronic, verbal, or written communication sent to the Licensor or its representatives, including but not limited to communication on electronic mailing lists, source code control systems, and issue tracking systems that are managed by, or on behalf of, the Licensor for the purpose of discussing and improving the Work, but excluding communication that is conspicuously marked or otherwise designated in writing by the copyright owner as \"Not a Contribution.\"";
		case 61:
			return @"\"Contributor\" shall mean Licensor and any individual or Legal Entity on behalf of whom a Contribution has been received by Licensor and subsequently incorporated within the Work.";
		case 62:
			return @"2. Grant of Copyright License. Subject to the terms and conditions of this License, each Contributor hereby grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable copyright license to reproduce, prepare Derivative Works of, publicly display, publicly perform, sublicense, and distribute the Work and such Derivative Works in Source or Object form.";
		case 63:
			return @"3. Grant of Patent License. Subject to the terms and conditions of this License, each Contributor hereby grants to You a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable (except as stated in this section) patent license to make, have made, use, offer to sell, sell, import, and otherwise transfer the Work, where such license applies only to those patent claims licensable by such Contributor that are necessarily infringed by their Contribution(s) alone or by combination of their Contribution(s) with the Work to which such Contribution(s) was submitted. If You institute patent litigation against any entity (including a cross-claim or counterclaim in a lawsuit) alleging that the Work or a Contribution incorporated within the Work constitutes direct or contributory patent infringement, then any patent licenses granted to You under this License for that Work shall terminate as of the date such litigation is filed.";
		case 64:
			return @"4. Redistribution. You may reproduce and distribute copies of the Work or Derivative Works thereof in any medium, with or without modifications, and in Source or Object form, provided that You meet the following conditions:";
		case 65:
			return @"(a) You must give any other recipients of the Work or Derivative Works a copy of this License; and";
		case 66:
			return @"(b) You must cause any modified files to carry prominent notices stating that You changed the files; and";
		case 67:
			return @"(c) You must retain, in the Source form of any Derivative Works that You distribute, all copyright, patent, trademark, and attribution notices from the Source form of the Work, excluding those notices that do not pertain to any part of the Derivative Works; and";
		case 68:
			return @"(d) If the Work includes a \"NOTICE\" text file as part of its distribution, then any Derivative Works that You distribute must include a readable copy of the attribution notices contained within such NOTICE file, excluding those notices that do not pertain to any part of the Derivative Works, in at least one of the following places: within a NOTICE text file distributed as part of the Derivative Works; within the Source form or documentation, if provided along with the Derivative Works; or, within a display generated by the Derivative Works, if and wherever such third-party notices normally appear. The contents of the NOTICE file are for informational purposes only and do not modify the License. You may add Your own attribution notices within Derivative Works that You distribute, alongside or as an addendum to the NOTICE text from the Work, provided that such additional attribution notices cannot be construed as modifying the License.";
		case 69:
			return @"You may add Your own copyright statement to Your modifications and may provide additional or different license terms and conditions for use, reproduction, or distribution of Your modifications, or for any such Derivative Works as a whole, provided Your use, reproduction, and distribution of the Work otherwise complies with the conditions stated in this License.";
		case 70:
			return @"5. Submission of Contributions. Unless You explicitly state otherwise, any Contribution intentionally submitted for inclusion in the Work by You to the Licensor shall be under the terms and conditions of this License, without any additional terms or conditions. Notwithstanding the above, nothing herein shall supersede or modify the terms of any separate license agreement you may have executed with Licensor regarding such Contributions.";
		case 71:
			return @"6. Trademarks. This License does not grant permission to use the trade names, trademarks, service marks, or product names of the Licensor, except as required for reasonable and customary use in describing the origin of the Work and reproducing the content of the NOTICE file.";
		case 72:
			return @"7. Disclaimer of Warranty. Unless required by applicable law or agreed to in writing, Licensor provides the Work (and each Contributor provides its Contributions) on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied, including, without limitation, any warranties or conditions of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE. You are solely responsible for determining the appropriateness of using or redistributing the Work and assume any risks associated with Your exercise of permissions under this License.";
		case 73:
			return @"8. Limitation of Liability. In no event and under no legal theory, whether in tort (including negligence), contract, or otherwise, unless required by applicable law (such as deliberate and grossly negligent acts) or agreed to in writing, shall any Contributor be liable to You for damages, including any direct, indirect, special, incidental, or consequential damages of any character arising as a result of this License or out of the use or inability to use the Work (including but not limited to damages for loss of goodwill, work stoppage, computer failure or malfunction, or any and all other commercial damages or losses), even if such Contributor has been advised of the possibility of such damages.";
		case 74:
			return @"9. Accepting Warranty or Additional Liability. While redistributing the Work or Derivative Works thereof, You may choose to offer, and charge a fee for, acceptance of support, warranty, indemnity, or other liability obligations and/or rights consistent with this License. However, in accepting such obligations, You may act only on Your own behalf and on Your sole responsibility, not on behalf of any other Contributor, and only if You agree to indemnify, defend, and hold each Contributor harmless for any liability incurred by, or claims asserted against, such Contributor by reason of your accepting any such warranty or additional liability.";
		case 75:
			return @"END OF TERMS AND CONDITIONS";
		case 76:
			return @"APPENDIX: How to apply the Apache License to your work.";
		case 77:
			return @"To apply the Apache License to your work, attach the following boilerplate notice, with the fields enclosed by brackets \"[]\" replaced with your own identifying information. (Don't include the brackets!)  The text should be enclosed in the appropriate comment syntax for the file format. We also recommend that a file or class name and description of purpose be included on the same \"printed page\" as the copyright notice for easier identification within third-party archives.";
		case 78:
			return @"Copyright [yyyy] [name of copyright owner]";
		case 79:
			return @"Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this file except in compliance with the License. You may obtain a copy of the License at";
		case 80:
			return @"http://www.apache.org/licenses/LICENSE-2.0";
		case 81:
			return @"Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\nSee the License for the specific language governing permissions and limitations under the License.";
		case 82:
			return @"-----";
		case 83:
			return @"Copyright 2007 Kaboomerang LLC. All rights reserved.";
		case 84:
			return @"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:";
		case 85:
			return @"The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.";
		case 86:
			return @"THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.";
		case 87:
			return @"-----";
		case 88:
			return @"The following software may be included in this product: MGTwitterEngine. This software contains the following license and notice below:";
		case 89:
			return @"License Agreement for Source Code provided by Matt Gemmell";
		case 90:
			return @"This software is supplied to you by Matt Gemmell in consideration of your agreement to the following terms, and your use, installation, modification or redistribution of this software constitutes acceptance of these terms. If you do not agree with these terms, please do not use, install, modify or redistribute this software.";
		case 91:
			return @"In consideration of your agreement to abide by the following terms, and subject to these terms, Matt Gemmell grants you a personal, non-exclusive license, to use, reproduce, modify and redistribute the software, with or without modifications, in source and/or binary forms; provided that if you redistribute the software in its entirety and without modifications, you must retain this notice and the following text and disclaimers in all such redistributions of the software, and that in all cases attribution of Matt Gemmell as the original author of the source code shall be included in all such resulting software products or distributions.";
		case 92:
			return @"Neither the name, trademarks, service marks or logos of Matt Gemmell or Instinctive Code may be used to endorse or promote products derived from the software without specific prior written permission from Matt Gemmell. Except as expressly stated in this notice, no other rights or licenses, express or implied, are granted by Matt Gemmell herein, including but not limited to any patent rights that may be infringed by your derivative works or by other works in which the software may be incorporated.";
		case 93:
			return @"The software is provided by Matt Gemmell on an \"AS IS\" basis. MATT GEMMELL AND INSTINCTIVE CODE MAKE NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.";
		case 94:
			return @"IN NO EVENT SHALL MATT GEMMELL OR INSTINCTIVE CODE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF MATT GEMMELL OR INSTINCTIVE CODE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.";
		case 95:
			return @"-----";
		case 96:
			return @"Includes MGTwitterEngine code by Matt Gemmell.\nhttp://mattgemmell.com/";
		case 97:
			return @"-----";
		case 98:
			return @"The following software may be included in this product: NSData+Base64. This software contains the following license and notice below:";
		case 99:
			return @"Derived from http://colloquy.info/project/browser/trunk/NSDataAdditions.h?rev=1576\nCreated by khammond on Mon Oct 29 2001.\nFormatted by Timothy Hatcher on Sun Jul 4 2004.\nCopyright (c) 2001 Kyle Hammond. All rights reserved.\nOriginal development by Dave Winer.";
		case 100:
			return @"-----";
		case 101:
			return @"The following software may be included in this product: Twitter+OAuth. This software contains the following license and notice below:";
		case 102:
			return @"Twitter+OAuth Source and Example for iPhone\nGlommed together by Ben Gottlieb\ncopyright 2009 Stand Alone, Inc - all rights reserved.\nLicense: BSD, If you use it, please include the following text somewhere in your application's user-facing text:\n\"Includes Twitter+OAuth code by Ben Gottlieb\"";
		case 103:
			return @"-----";
		case 104:
			return @"Includes Twitter+OAuth code by Ben Gottlieb";
		case 105:
			return @"-----";
		case 106:
			return @"The following software may be included in this product: Google AdMob Ads SDK. This software contains the following license and notice below:";
		case 107:
			return @"Google AdMob Ads SDK";
		case 108:
			return @"Copyright 2011 Google Inc. All rights reserved.";
		case 109:
			return @"-----";
		case 110:
			return @"Google AdMob Ads SDK";
		case 111:
			return @"Copyright 2012 Google Inc. All rights reserved.";
		case 112:
			return @"-----";
		case 113:
			return @"Google Ads iOS SDK";
		case 114:
			return @"Copyright 2012 Google Inc. All rights reserved.";
		case 115:
			return @"-----";
		case 116:
			return @"Google Ads iOS SDK";
		case 117:
			return @"Copyright (c) 2012 Google Inc. All rights reserved.";
		case 118:
			return @"-----";
		case 119:
			return @"The following software may be included in this product: GADCustomEventExtras.h. This software contains the following license and notice below:";
		case 120:
			return @"GADCustomEventExtras.h\nGoogle Ads iOS SDK";
		case 121:
			return @"Created by Lynn Nguyen on 3/15/12.\nCopyright (c) 2012 Google Inc. All rights reserved.";
		case 122:
			return @"-----";
		default:
			return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

@end
