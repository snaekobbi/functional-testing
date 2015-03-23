import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Hashtable;
import java.util.Map;
import java.util.regex.Pattern;
import javax.inject.Inject;
import javax.xml.transform.stream.StreamSource;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.collect.Collections2;
import com.google.common.collect.HashMultimap;
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
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;
import org.daisy.maven.xspec.XSpecRunner;

import org.daisy.pipeline.braille.common.CSSBlockTransform;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.Transform.AbstractTransform;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.XProcTransform;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;
import static org.daisy.pipeline.pax.exam.Options.xprocspecBundles;
import static org.daisy.pipeline.pax.exam.Options.xspecBundles;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.JUnitCore;
import org.junit.runner.notification.Failure;
import org.junit.runner.Result;
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

import org.osgi.framework.BundleContext;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-utils.api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-utils.pef-tools").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-utils.impl").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			mavenBundle().groupId("org.unbescape").artifactId("unbescape").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.common").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.translator.impl").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.formatter.impl").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-css").versionAsInProject(),
			mavenBundle().groupId("org.daisy.bindings").artifactId("jhyphen").versionAsInProject(),
			brailleModule("common-utils"),
			brailleModule("dotify-core"),
			brailleModule("dotify-saxon"),
			brailleModule("dotify-calabash"),
			brailleModule("dotify-utils"),
			brailleModule("dotify-formatter"),
			brailleModule("liblouis-core"),
			brailleModule("liblouis-saxon"),
			brailleModule("liblouis-calabash"),
			brailleModule("liblouis-utils"),
			brailleModule("liblouis-tables"),
			brailleModule("libhyphen-core"),
			forThisPlatform(brailleModule("liblouis-native")),
			brailleModule("css-core"),
			brailleModule("css-calabash"),
			brailleModule("css-utils"),
			brailleModule("pef-core"),
			brailleModule("pef-calabash"),
			brailleModule("pef-saxon"),
			brailleModule("pef-utils"),
			pipelineModule("file-utils"),
			xprocspecBundles(),
			xspecBundles(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("saxon-adapter").versionAsInProject(),
			junitBundles()
		);
	}
	
	@Inject
	private BundleContext context;
	
	@Before
	public void registerBypassBlockTransformProvider() {
		BypassBlockTransform.Provider provider = new BypassBlockTransform.Provider();
		Hashtable<String,Object> properties = new Hashtable<String,Object>();
		context.registerService(CSSBlockTransform.Provider.class.getName(), provider, properties);
		context.registerService(XProcTransform.Provider.class.getName(), provider, properties);
	}
	
	private static class BypassBlockTransform extends AbstractTransform implements CSSBlockTransform, XProcTransform {
		private final URI href = asURI(new File(new File(PathUtils.getBaseDir()), "identity.xpl"));
		public Tuple3<URI,javax.xml.namespace.QName,Map<String,String>> asXProc() {
			return new Tuple3<URI,javax.xml.namespace.QName,Map<String,String>>(href, null, null);
		}
		private static final Iterable<BypassBlockTransform> instance = Optional.of(new BypassBlockTransform()).asSet();
		private static final Iterable<BypassBlockTransform> empty = Optional.<BypassBlockTransform>absent().asSet();
		public static class Provider implements CSSBlockTransform.Provider<BypassBlockTransform>, XProcTransform.Provider<BypassBlockTransform> {
			public Iterable<BypassBlockTransform> get(String query) {
				return query.equals("(translator:bypass)") ? instance : empty;
			}
			public Transform.Provider<BypassBlockTransform> withContext(Logger context) {
				return this;
			}
		}
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
		File testsDir = new File(srcDir, "test");
		File reportsDir = new File(destDir, "report");
		XsltCompiler compiler = processor.newXsltCompiler();
		
		/*
		 * Run JUnit tests
		 */
		Collection<File> junitFiles = listFilesRecursively(testsDir, Pattern.compile(".+\\.java"));
		Class[] junitClasses = new Class[junitFiles.size()];
		int i = 0;
		for (File f : junitFiles)
			try {
				junitClasses[i++] = Class.forName(
					testsDir.toPath().relativize(f.toPath()).toString().replaceAll("\\.java$", "").replace('/', '.')); }
			catch (ClassNotFoundException e) {
				throw new RuntimeException(e); }
		JUnitCore junitRunner = new JUnitCore();
		Result junitResult = junitRunner.run(junitClasses);
		HashMultimap<String,String> failedTests = HashMultimap.<String,String>create();
		for (Failure fail : junitResult.getFailures())
			if (fail.getDescription().isTest()) {
				logger.error("Junit test failed", fail.getException());
				for (StackTraceElement e : fail.getException().getStackTrace()) {
					String n = e.getClassName();
					for (Class c : junitClasses)
						if (c.getName().equals(n)) {
							failedTests.put(n, e.getMethodName());
							break; }}}
		
		File junitReportsDir = new File(reportsDir, "junit");
		junitReportsDir.mkdirs();
		Collection<File> junitReports = new ArrayList<File>();
		for (Class c : junitClasses) {
			String n = c.getName();
			URI classFile = new File(testsDir, n.replace('.', '/') + ".java").toURI();
			File report = new File(junitReportsDir, n + ".xml");
			junitReports.add(report);
			PrintWriter writer = new PrintWriter(report);
			if (failedTests.containsKey(n)) {
				writer.write("<testFile href=\"" + classFile + "\" result=\"failed\">");
				for (String m : failedTests.get(n))
					writer.write("<testCase name=\"" + m + "\" result=\"failed\"/>");
				writer.write("</testFile>"); }
			else
				writer.write("<testFile href=\"" + classFile + "\" result=\"passed\"/>");
			writer.close(); }
		
		/*
		 * Run XProcSpec tests
		 */
		Collection<File> xprocspecFiles = listFilesRecursively(testsDir, Pattern.compile(".+\\.xprocspec"));
		File xprocspecReportsDir = new File(reportsDir, "xprocspec");
		xprocspecRunner.run(testsDir,
		                    xprocspecReportsDir,
		                    xprocspecReportsDir,
		                    new File(baseDir, "target/xprocspec"),
		                    new XProcSpecRunner.Reporter.DefaultReporter());
		Collection<File> xprocspecReports = listFilesRecursively(xprocspecReportsDir, Pattern.compile(".+(?<!^index)\\.html"));
		
		/*
		 * Run XSpec tests
		 */
		Collection<File> xspecFiles = listFilesRecursively(testsDir, Pattern.compile(".+\\.xspec"));
		File xspecReportsDir = new File(reportsDir, "xspec");
		xspecReportsDir.mkdirs();
		xspecRunner.run(testsDir, xspecReportsDir);
		Collection<File> xspecReports = listFilesRecursively(xspecReportsDir, Pattern.compile(".+(?<!^index)\\.html"));
		
		/*
		 * Style test sources
		 */
		for (File f : Iterables.<File>concat(junitFiles, xprocspecFiles, xspecFiles)) {
			File xslt = new File(f + ".xsl");
			if (xslt.exists())
				transform(compiler.compile(new StreamSource(xslt)).load(),
				          f.getPath().endsWith(".java") ? null : f,
				          renameTestSourceFile(f, srcDir, destDir));
			else
				copy(f, renameTestSourceFile(f, srcDir, destDir)); }
		
		/*
		 * Process index.xhtml
		 */
		XsltTransformer processIndex = compiler.compile(new StreamSource(new File(baseDir, "process-index.xsl"))).load();
		processIndex.setParameter(new QName("junit-reports"), new XdmValue(
				Collections2.<File,XdmItem>transform(junitReports, fileAsXdmItem)));
		processIndex.setParameter(new QName("xprocspec-reports"), new XdmValue(
				Collections2.<File,XdmItem>transform(xprocspecReports, fileAsXdmItem)));
		processIndex.setParameter(new QName("xspec-reports"), new XdmValue(
				Collections2.<File,XdmItem>transform(xspecReports, fileAsXdmItem)));
		processIndex.setParameter(new QName("result-base"), new XdmAtomicValue(
				new File(destDir, "index.xhtml").toURI()));
		transform(processIndex, new File(srcDir, "index.xhtml"), new File(destDir, "index.xhtml"));
		
		/*
		 * Process test reports
		 */
		XsltExecutable processReportExec = compiler.compile(new StreamSource(new File(baseDir, "process-report.xsl")));
		for (File f : Iterables.<File>concat(junitReports, xprocspecReports, xspecReports)) {
			XsltTransformer processReport = processReportExec.load();
			processReport.setParameter(new QName("src-dir_"), new XdmAtomicValue(srcDir.toURI()));
			processReport.setParameter(new QName("dest-dir_"), new XdmAtomicValue(destDir.toURI()));
			processReport.setParameter(new QName("result-base"), new XdmAtomicValue(f.toURI()));
			transform(processReport, f, f); }
	}
	
	private static void transform(XsltTransformer transformer, File source, File destination) throws SaxonApiException, IOException {
		if (source == null)
			transformer.setInitialTemplate(new QName("main"));
		else
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
	
	private static final Logger logger = LoggerFactory.getLogger(RunTestsAndProcessFiles.class);
}
