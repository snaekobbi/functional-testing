package hyphenation;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static com.google.common.base.Predicates.instanceOf;
import static com.google.common.collect.Iterables.find;

import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.Transform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.dispatch;
import org.daisy.pipeline.braille.libhyphen.LibhyphenHyphenator;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

import org.ops4j.pax.exam.util.PathUtils;

import org.osgi.framework.BundleContext;
import static org.osgi.framework.FrameworkUtil.getBundle;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.framework.ServiceReference;

public class test_no {
	
	@Test
	public void testNorwegianHyphenation() throws IOException {
		Transform.Provider<LibhyphenHyphenator> provider = getProvider(LibhyphenHyphenator.class, LibhyphenHyphenator.Provider.class);
		Hyphenator hyphenator = provider.get("(locale:no)").iterator().next();
		BufferedReader data = new BufferedReader(new FileReader(
			new File(new File(PathUtils.getBaseDir()), "src/resources/hyphenation/data_no.txt")));
		String expected;
		String word;
		String hyphenated;
		while ((expected = data.readLine()) != null) {
			word = expected.replaceAll("\u00ad", "");
			hyphenated = hyphenator.transform(word);
			assertCorrectlyHyphenatedIgnoreFalsePositives(expected, hyphenated); }
	}
	
	private void assertCorrectlyHyphenatedIgnoreFalsePositives(String expected, String actual) {
		try {
			char a;
			int i = 0;
			for (char e : expected.toCharArray()) {
				switch (e) {
				case '\u00ad':
					a = actual.charAt(i++);
					break;
				default:
					while (true) {
						a = actual.charAt(i++);
						if (a != '\u00ad') break; }}
				assertEquals(e, a); }
			assertEquals(actual.length(), i);
			return; }
		catch (Throwable t) {}
		throw new AssertionError("Not correctly hyphenated\nexpected: " + expected + "\nwas: " + actual);
	}
	
	private static BundleContext context = getBundle(test_no.class).getBundleContext();
	
	private <T extends Transform> Transform.Provider<T> getProvider(Class<T> transformerClass, Class<? extends Transform.Provider<T>> providerClass) {
		List<Transform.Provider<T>> providers = new ArrayList<Transform.Provider<T>>();
		try {
			for (ServiceReference<? extends Transform.Provider<T>> ref : context.getServiceReferences(providerClass, null))
				providers.add(context.getService(ref)); }
		catch (InvalidSyntaxException e) {
			throw new RuntimeException(e); }
		return dispatch(providers);
	}
}
