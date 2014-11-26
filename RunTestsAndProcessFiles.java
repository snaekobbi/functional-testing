import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.net.URL;
import java.util.Collection;
import java.util.regex.Pattern;
import javax.inject.Inject;
import javax.xml.transform.stream.StreamSource;

import com.google.common.base.Function;
import com.google.common.collect.Collections2;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Iterables;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmDestination;
import net.sf.saxon.s9api.XdmItem;
import net.sf.saxon.s9api.XdmValue;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltTransformer;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;
import org.daisy.maven.xspec.XSpecRunner;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
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
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("brailleutils-core").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.common").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.translator.impl").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.formatter.impl").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			brailleModule("common-utils"),
			brailleModule("dotify-calabash"),
			brailleModule("dotify-formatter"),
			brailleModule("liblouis-core"),
			brailleModule("liblouis-saxon"),
			forThisPlatform(brailleModule("liblouis-native")),
			brailleModule("css-core"),
			brailleModule("css-calabash"),
			brailleModule("css-utils"),
			brailleModule("pef-calabash"),
			brailleModule("pef-saxon"),
			brailleModule("pef-to-html"),
			brailleModule("pef-utils"),
			pipelineModule("file-utils"),
			xprocspecBundles(),
			xspecBundles(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("saxon-adapter").versionAsInProject(),
			junitBundles()
		);
	}
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
	
	@Inject
	private XSpecRunner xspecRunner;
	
	@Inject
	private Processor processor;
	
	@Test
	public void run() throws SaxonApiException, IOException {
		File baseDir = new File(PathUtils.getBaseDir());
		File srcDir = new File(baseDir, "src");
		File destDir = new File(baseDir, "target/site");
		String testsPath = "test";
		String reportsPath = "report";
		File testsDir = new File(srcDir, testsPath);
		File reportsDir = new File(destDir, reportsPath);
		File xprocspecReportsDir = new File(reportsDir, "xprocspec");
		File xspecReportsDir = new File(reportsDir, "xspec");
		xprocspecRunner.run(testsDir,
		                    xprocspecReportsDir,
		                    xprocspecReportsDir,
		                    new File(baseDir, "target/xprocspec"),
		                    new XProcSpecRunner.Reporter.DefaultReporter());
		xspecReportsDir.mkdirs();
		xspecRunner.run(testsDir, xspecReportsDir);
		XsltCompiler compiler = processor.newXsltCompiler();
		Collection<File> xprocspecFiles = listFilesRecursively(testsDir, Pattern.compile(".+\\.xprocspec"));
		Collection<File> xspecFiles = listFilesRecursively(testsDir, Pattern.compile(".+\\.xspec"));
		Collection<File> xprocspecReports = listFilesRecursively(xprocspecReportsDir, Pattern.compile(".+(?<!^index)\\.html"));
		Collection<File> xspecReports = listFilesRecursively(xspecReportsDir, Pattern.compile(".+(?<!^index)\\.html"));
		for (File f : Iterables.<File>concat(xprocspecFiles, xspecFiles)) {
			File xslt = new File(f + ".xsl");
			if (xslt.exists())
				transform(compiler.compile(new StreamSource(xslt)).load(), f, renameTestSourceFile(f, srcDir, destDir));
			else
				copy(f, renameTestSourceFile(f, srcDir, destDir)); }
		XsltTransformer processIndex = compiler.compile(new StreamSource(new File(baseDir, "process-index.xsl"))).load();
		processIndex.setParameter(new QName("xprocspec-reports"), new XdmValue(
				Collections2.<File,XdmItem>transform(xprocspecReports, fileAsXdmItem)));
		processIndex.setParameter(new QName("xspec-reports"), new XdmValue(
				Collections2.<File,XdmItem>transform(xspecReports, fileAsXdmItem)));
		processIndex.setParameter(new QName("result-base"), new XdmAtomicValue(
				new File(destDir, "index.xhtml").toURI()));
		transform(processIndex, new File(srcDir, "index.xhtml"), new File(destDir, "index.xhtml"));
		XsltTransformer processReport = compiler.compile(new StreamSource(new File(baseDir, "process-report.xsl"))).load();
		processReport.setParameter(new QName("src-dir_"), new XdmAtomicValue(srcDir.toURI()));
		processReport.setParameter(new QName("dest-dir_"), new XdmAtomicValue(destDir.toURI()));
		for (File f : Iterables.<File>concat(xprocspecReports, xspecReports)) {
			processReport.setParameter(new QName("result-base"), new XdmAtomicValue(f.toURI()));
			transform(processReport, f, f); }
	}
	
	private static void transform(XsltTransformer transformer, File source, File destination) throws SaxonApiException, IOException {
		transformer.setSource(new StreamSource(source));
		XdmDestination dest = new XdmDestination();
		transformer.setDestination(dest);
		transformer.transform();
		new Serializer(destination).serializeNode(dest.getXdmNode());
	}
	
	private static void copy(File source, File destination) throws IOException {
		destination.getParentFile().mkdirs();
		destination.createNewFile();
		FileOutputStream writer = new FileOutputStream(destination);
		URL url = source.toURI().toURL();
		url.openConnection();
		InputStream reader = url.openStream();
		byte[] buffer = new byte[153600];
		int bytesRead = 0;
		while ((bytesRead = reader.read(buffer)) > 0) {
			writer.write(buffer, 0, bytesRead);
			buffer = new byte[153600]; }
		writer.close();
		reader.close();
	}
	
	private static File renameTestSourceFile(File file, File srcDir, File destDir) throws IOException {
		return new File(destDir, file.getCanonicalPath().substring(srcDir.getCanonicalPath().length()) + ".xhtml");
	}
	
	private static Function<File,XdmItem> fileAsXdmItem = new Function<File,XdmItem>() {
		public XdmItem apply(File file) {
			return new XdmAtomicValue(file.toURI());
		}
	};
	
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
