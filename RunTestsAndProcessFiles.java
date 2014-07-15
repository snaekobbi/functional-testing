import java.io.File;
import java.util.Collection;
import java.util.regex.Pattern;
import javax.inject.Inject;
import javax.xml.transform.stream.StreamSource;

import com.google.common.base.Function;
import com.google.common.collect.Collections2;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmItem;
import net.sf.saxon.s9api.XdmValue;
import net.sf.saxon.s9api.XsltTransformer;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;

import static org.daisy.pipeline.pax.exam.Options.calabashConfigFile;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;
import static org.daisy.pipeline.pax.exam.Options.spiflyBundles;
import static org.daisy.pipeline.pax.exam.Options.xprocspecBundles;
import static org.daisy.pipeline.pax.exam.Options.xspecBundles;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertTrue;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.options.MavenArtifactProvisionOption;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemProperty;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class RunTestsAndProcessFiles {
	
	@Configuration
	public Option[] config() {
		return options(
			systemProperty("logback.configurationFile").value("file:" + PathUtils.getBaseDir() + "/logback.xml"),
			systemProperty("org.daisy.pipeline.xproc.configuration").value(PathUtils.getBaseDir() + "/config-calabash.xml"),
			systemProperty("com.xmlcalabash.config.user").value(""),
			domTraversalPackage(),
			logbackBundles(),
			felixDeclarativeServices(),
			spiflyBundles(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("brailleutils-core").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("brailleutils-catalog").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			pipelineBrailleModule("common-java"),
			pipelineBrailleModule("liblouis-core"),
			pipelineBrailleModule("liblouis-calabash"),
			pipelineBrailleModule("liblouis-formatter"),
			pipelineBrailleModule("css-core"),
			pipelineBrailleModule("css-calabash"),
			pipelineBrailleModule("css-utils"),
			pipelineBrailleModule("pef-calabash"),
			pipelineBrailleModule("pef-saxon"),
			pipelineBrailleModule("pef-to-html"),
			pipelineBrailleModule("pef-utils"),
			pipelineBrailleModule("common-utils"),
			forThisPlatform(pipelineBrailleModule("liblouis-native")),
			pipelineModule("file-utils"),
			pipelineModule("common-utils"),
			pipelineModule("html-utils"),
			pipelineModule("zip-utils"),
			pipelineModule("mediatype-utils"),
			pipelineModule("fileset-utils"),
			xprocspecBundles(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("saxon-adapter").versionAsInProject(),
			junitBundles()
		);
	}
	
	private static MavenArtifactProvisionOption pipelineBrailleModule(String artifactId) {
		return mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId(artifactId).versionAsInProject();
	}
	
	@Inject
	private XProcSpecRunner runner;
	
	@Inject
	private Processor processor;
	
	@Test
	public void run() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		File testsDir = new File(baseDir, "src/xprocspec");
		File reportsDir = new File(baseDir, "target/xprocspec-reports");
		runner.run(testsDir,
		           reportsDir,
		           new File(baseDir, "target/surefire-reports"),
		           new File(baseDir, "target/xprocspec"),
		           new XProcSpecRunner.Reporter.DefaultReporter());
		XsltTransformer processFiles = processor.newXsltCompiler().compile(
				new StreamSource(new File(baseDir, "process-files.xsl"))).load();
		processFiles.setSource(new StreamSource(new File(baseDir, "src/index.xhtml")));
		processFiles.setParameter(new QName("result"), new XdmAtomicValue(
				new File(baseDir, "target/classes/index.xhtml").toURI()));
		processFiles.setParameter(new QName("xprocspec-tests"), new XdmValue(
				Collections2.<File,XdmItem>transform(
					listFilesRecursively(testsDir, Pattern.compile(".+\\.xprocspec")),
					new Function<File,XdmItem>() {
						public XdmItem apply(File test) {
							return new XdmAtomicValue(test.toURI()); }})));
		processFiles.setParameter(new QName("xprocspec-reports"), new XdmValue(
				Collections2.<File,XdmItem>transform(
					listFilesRecursively(reportsDir, Pattern.compile(".+(?<!^index)\\.html")),
					new Function<File,XdmItem>() {
						public XdmItem apply(File test) {
							return new XdmAtomicValue(test.toURI()); }})));
		processFiles.setDestination(new XdmDestination());
		processFiles.transform();
	}
	
	private static Collection<File> listFilesRecursively(File directory, final Pattern pattern) {
		ImmutableList.Builder<File> builder = new ImmutableList.Builder<File>();
		for (File file : directory.listFiles()) {
			if (file.isDirectory())
				builder.addAll(listFilesRecursively(file, pattern));
			else if (pattern.matcher(file.getName()).matches())
				builder.add(file); }
		return builder.build();
	}
}
